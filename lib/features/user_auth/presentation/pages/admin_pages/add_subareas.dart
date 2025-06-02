import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_appbar.dart'
    show AdminAppBar;
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_navbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/subarea_item.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/floating_plus_action_button.dart';
import 'package:flutter_app_5s/utils/global_states/admin_id_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_app_5s/auth/auth_service.dart';

class AddSubArea extends StatefulWidget {
  const AddSubArea({super.key});

  @override
  State<AddSubArea> createState() => _AddSubAreaState();
}

class _AddSubAreaState extends State<AddSubArea> {
  List<Map<String, dynamic>> subAreas = [];
  bool isLoading = true;
  String? errorMessage;
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idProvider = Provider.of<AdminIdProvider>(context, listen: false);
      if (idProvider.orgId == null || idProvider.areaId == null) {
        context.goNamed('OrganizationsListPage');
      }
    });
    _fetchSubAreas();
  }

  Future<void> _fetchSubAreas() async {
    final idProvider = Provider.of<AdminIdProvider>(context, listen: false);
    final orgId = idProvider.orgId;
    final areaId = idProvider.areaId;

    if (orgId == null || areaId == null) {
      setState(() {
        errorMessage = 'Faltan IDs necesarios';
        isLoading = false;
      });
      return;
    }

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

    print(
        'Obteniendo subáreas para el área: $areaId de la organización: $orgId');
    print('URL: $baseUrl/org/$orgId/area/$areaId/subarea');
    print('Token: Bearer ${accessToken.substring(0, 20)}...');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/org/$orgId/area/$areaId/subarea'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Tipo de datos recibidos: ${data.runtimeType}');
        print('Datos recibidos: $data');

        if (data is List) {
          print('Subáreas encontradas: ${data.length}');
          setState(() {
            subAreas = data.map((item) {
              print('Procesando item: $item');
              return {
                'id': item['id'].toString(),
                'title': item['name'] ?? 'Sin nombre',
              };
            }).toList();
            isLoading = false;
          });
          print('Subáreas procesadas: $subAreas');
        } else {
          print('Error: La respuesta no es una lista');
          setState(() {
            errorMessage = 'Formato de respuesta inválido';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage =
              'Sesión expirada. Por favor, inicie sesión nuevamente.';
          isLoading = false;
        });
        context.goNamed('AdminAccessPage');
      } else {
        setState(() {
          errorMessage =
              'Error al cargar departamentos: ${response.statusCode}\n${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al obtener subáreas: $e');
      setState(() {
        errorMessage = 'Error de conexión: $e';
        isLoading = false;
      });
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
    return Scaffold(
      appBar: AdminAppBar(
        title: "Subáreas",
        onBackPressed: () {
          context.goNamed('AreaMenu');
        },
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Container(
                color: colorScheme.surface,
                child: subAreas.isEmpty
                    ? const Center(
                        child: Text('No hay departamentos para mostrar'),
                      )
                    : ListView.builder(
                        itemCount: subAreas.length,
                        itemBuilder: (context, index) {
                          final department = subAreas[index];
                          print(
                              'Construyendo item para: ${department['title']}');
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: SubAreaItem(
                              title: department['title'],
                              onTap: () => _handleSubAreaTap(department['id']),
                            ),
                          );
                        },
                      )),
          ),
          const AdminNavBar(),
          FloatingPlusActionButton(
            onPressed: () {
              //TODO : Agregar funcionalidad
              print("AddDepartment");
            },
          )
        ],
      ),
    );
  }

  void _handleSubAreaTap(String id) {
    final idProvider = Provider.of<AdminIdProvider>(context, listen: false);
    idProvider.setSubareaId(id);
    context.pushNamed('FiveSMenu');
  }
}
