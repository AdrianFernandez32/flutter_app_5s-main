import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_appbar.dart'
    show AdminAppBar;
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_navbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/area_item.dart';
import 'package:flutter_app_5s/utils/global_states/admin_id_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_app_5s/auth/auth_service.dart';

class AreaMenu extends StatefulWidget {
  const AreaMenu({super.key});

  @override
  State<AreaMenu> createState() => _AreaMenuState();
}

class _AreaMenuState extends State<AreaMenu> {
  List<Map<String, dynamic>> areas = [];
  bool isLoading = true;
  String? errorMessage;
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idProvider = Provider.of<AdminIdProvider>(context, listen: false);
      if (idProvider.orgId == null) {
        context.goNamed('OrgMenu');
      }
    });
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    final idProvider = Provider.of<AdminIdProvider>(context, listen: false);
    final orgId = idProvider.orgId;

    if (orgId == null) {
      setState(() {
        errorMessage = 'Organización no encontrada';
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

    print('Obteniendo áreas para la organización: $orgId');
    print('URL: $baseUrl/org/$orgId/area');
    print('Token: Bearer ${accessToken.substring(0, 20)}...');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/org/$orgId/area'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        debugPrint('Datos recibidos: ${data.length}');
        setState(() {
          areas = data
              .map((item) => {
                    'id': item['id'].toString(),
                    'name': item['name'] ?? '',
                    'description': item['description'] ?? '',
                    'logoUrl': item['logoUrl'] ?? '',
                  })
              .toList();
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage =
              'Sesión expirada. Por favor, inicie sesión nuevamente.';
          isLoading = false;
        });
        // Redirigir al login
        context.goNamed('AdminAccessPage');
      } else {
        setState(() {
          errorMessage =
              'Error al cargar áreas: ${response.statusCode}\n${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al obtener áreas: $e');
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
        title: "Areas",
        onBackPressed: () {
          AdminIdProvider().clearOrgId();
          context.pushNamed(
            'AdminDashboard',
          );
        },
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Container(
                color: colorScheme.surface,
                child: ListView(
                  children: [
                    ...areas
                        .map((area) => AreaItem(
                              id: area['id'],
                              name: area['name'],
                              description: area['description'],
                              logoUrl: area['logoUrl'],
                              onTap: () => _handleDepartmentTap(area['id']),
                            ))
                        .toList(),
                  ],
                )),
          ),
          const AdminNavBar(),
        ],
      ),
    );
  }

  void _handleDepartmentTap(String id) {
    final idProvider = Provider.of<AdminIdProvider>(context, listen: false);
    idProvider.setAreaId(id);

    context.pushNamed(
      'AddSubArea',
    );
  }
}
