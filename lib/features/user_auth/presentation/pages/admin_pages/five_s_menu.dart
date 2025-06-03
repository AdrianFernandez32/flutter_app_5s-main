import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_appbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_navbar.dart';
import 'package:flutter_app_5s/utils/global_states/admin_id_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_5s/auth/auth_service.dart';
import 'package:provider/provider.dart';

class FiveSMenu extends StatefulWidget {
  final String subareaId;
  final String subareaName;

  const FiveSMenu({
    super.key,
    required this.subareaId,
    required this.subareaName,
  });

  @override
  State<FiveSMenu> createState() => _FiveSMenuState();
}

class _FiveSMenuState extends State<FiveSMenu> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String? errorMessage;
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final accessToken = authService.accessToken;
      if (accessToken == null) {
        setState(() {
          errorMessage = 'No hay token de acceso disponible';
          isLoading = false;
        });
        return;
      }

      final baseUrl = dotenv.env['API_URL'];
      if (baseUrl == null) {
        setState(() {
          errorMessage = 'Error de configuración: API_URL no definida';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/base/categories/${widget.subareaId}'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        setState(() {
          categories = data
              .map((item) => {
                    'id': item['id'],
                    'name': item['name'],
                    'description': item['description'],
                    'scategory': item['scategory'],
                  })
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error al cargar categorías: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de conexión: $e';
        isLoading = false;
      });
    }
  }

  String _getSCategoryTitle(String scategory) {
    switch (scategory) {
      case 'S1':
        return 'Seiri (Clasificación)';
      case 'S2':
        return 'Seiton (Orden)';
      case 'S3':
        return 'Seiso (Limpieza)';
      case 'S4':
        return 'Seiketsu (Estandarización)';
      case 'S5':
        return 'Shitsuke (Disciplina)';
      default:
        return scategory;
    }
  }

  String _getSCategoryDescription(String scategory) {
    switch (scategory) {
      case 'S1':
        return 'Separar lo necesario de lo innecesario y eliminar lo que no se necesita.';
      case 'S2':
        return 'Organizar y disponer las cosas de manera que sean fáciles de encontrar y usar.';
      case 'S3':
        return 'Mantener limpio el lugar de trabajo y los equipos.';
      case 'S4':
        return 'Estandarizar las mejores prácticas y mantener el orden.';
      case 'S5':
        return 'Crear hábitos y mantener la disciplina en el cumplimiento de las normas.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    // Agrupar categorías por S
    final groupedCategories = <String, List<Map<String, dynamic>>>{};
    for (var category in categories) {
      final scategory = category['scategory'] as String;
      if (!groupedCategories.containsKey(scategory)) {
        groupedCategories[scategory] = [];
      }
      groupedCategories[scategory]!.add(category);
    }

    return Scaffold(
      appBar: AdminAppBar(
        title: widget.subareaName,
        onBackPressed: () {
          context.goNamed('AddSubArea');
        },
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedCategories.length,
              itemBuilder: (context, index) {
                final scategory = groupedCategories.keys.elementAt(index);
                final categories = groupedCategories[scategory]!;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(
                      _getSCategoryTitle(scategory),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(_getSCategoryDescription(scategory)),
                    children: categories.map((category) {
                      return ListTile(
                        title: Text(category['name']),
                        subtitle: Text(category['description']),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Guarda el baseCategoryId en el provider
                          Provider.of<AdminIdProvider>(context, listen: false)
                              .setBaseCategoryId(category['id'].toString());

                          // Navega a la pantalla de preguntas
                          context.goNamed(
                              "QuestionsPage"); 
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          const AdminNavBar(),
        ],
      ),
    );
  }
}
