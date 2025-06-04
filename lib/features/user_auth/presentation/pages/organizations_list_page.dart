import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app_5s/auth/auth_service.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app_5s/utils/global_states/admin_id_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OrganizationsListPage extends StatefulWidget {
  const OrganizationsListPage({Key? key}) : super(key: key);

  @override
  State<OrganizationsListPage> createState() => _OrganizationsListPageState();
}

class _OrganizationsListPageState extends State<OrganizationsListPage> {
  List<dynamic> organizations = [];
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? userRole;
  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchUserInfo();
    await fetchOrganizations();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final authService = AuthService();
      final accessToken = authService.accessToken;

      if (accessToken == null) {
        print('No hay token de acceso disponible');
        return;
      }

      // Primero obtenemos la información del usuario
      final whoamiResponse = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/user/whoami'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (whoamiResponse.statusCode == 200) {
        // El endpoint devuelve un texto plano con el ID
        final responseText = whoamiResponse.body;
        // Extraemos el ID del texto "User ID from JWT (sub): auth0|..."
        final idMatch = RegExp(r'auth0\|[a-zA-Z0-9]+').firstMatch(responseText);
        if (idMatch != null) {
          final extractedId = idMatch.group(0);
          print('ID de usuario extraído: $extractedId');
          setState(() {
            userId = extractedId;
          });

          // Ahora obtenemos los roles del usuario
          if (userId != null) {
            await _fetchUserRoles();
          }
        } else {
          print('No se pudo extraer el ID del usuario de la respuesta');
        }
      } else {
        print(
            'Error al obtener información del usuario: ${whoamiResponse.statusCode}');
      }
    } catch (e) {
      print('Error al obtener información del usuario: $e');
    }
  }

  Future<void> _fetchUserRoles() async {
    try {
      final authService = AuthService();
      final accessToken = authService.accessToken;

      if (accessToken == null || userId == null) {
        print('No hay token de acceso o ID de usuario disponible');
        return;
      }

      print('Obteniendo roles para el usuario: $userId');
      // Usamos el endpoint con el userId específico
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/user-roles/$userId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Respuesta de roles: $data');
        if (data is List && data.isNotEmpty) {
          setState(() {
            userRole = data[0]; // Tomamos el primer rol
          });
          print('Rol del usuario: ${userRole?['roleName']}');
        } else {
          print('No se encontraron roles para el usuario');
        }
      } else {
        print('Error al obtener el rol: ${response.statusCode}');
        print('Respuesta del servidor: ${response.body}');
      }
    } catch (e) {
      print('Error al obtener el rol: $e');
    }
  }

  Future<void> fetchOrganizations() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final authService = AuthService();
      final accessToken = authService.accessToken;
      final response = await http.get(
        Uri.parse('https://djnxv2fqbiqog.cloudfront.net/org/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          organizations = data is List ? data : [];
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error: \\${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de red: $e';
        isLoading = false;
      });
    }
  }

  void _showJoinDialog() {
    TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unirse a una organización'),
          content: TextField(
            controller: codeController,
            decoration: const InputDecoration(
              labelText: 'Código de acceso',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final inviteCode = codeController.text.trim();
                if (inviteCode.isEmpty) return;
                final authService = AuthService();
                final accessToken = authService.accessToken;
                Navigator.of(context).pop();
                if (accessToken == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Sesión expirada. Inicia sesión de nuevo.')),
                  );
                  return;
                }
                setState(() {
                  isLoading = true;
                });
                try {
                  final response = await http.post(
                    Uri.parse('https://djnxv2fqbiqog.cloudfront.net/org/join'),
                    headers: {
                      'Authorization': 'Bearer $accessToken',
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode({'inviteCode': inviteCode}),
                  );
                  if (response.statusCode == 200) {
                    await fetchOrganizations();
                    setState(() {
                      isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('¡Te has unido a la organización!')),
                    );
                  } else {
                    setState(() {
                      isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Error al unirse: \\${response.statusCode}')),
                    );
                  }
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error de red: $e')),
                  );
                }
              },
              child: const Text('Unirse'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleOrganizationTap(Map<String, dynamic> org) async {
    final authService = AuthService();
    final adminIdProvider =
        Provider.of<AdminIdProvider>(context, listen: false);
    final orgId = org['id']?.toString();

    if (orgId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID de organización no válido')),
      );
      return;
    }

    // Establecer el orgId en el provider
    adminIdProvider.setOrgId(orgId);
    authService.organizationId = orgId;

    // Verificar si el usuario es admin
    if (userRole != null && userRole!['roleName'] == 'ADMIN') {
      print('Redirigiendo a AdminDashboard - Usuario es ADMIN');
      context.goNamed('AdminDashboard');
    } else {
      print('Redirigiendo a Menu - Usuario no es ADMIN');
      context.goNamed('Menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('JWT actual: \\${AuthService().accessToken}');
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Organizaciones', style: TextStyle(color: Colors.white)),
        backgroundColor: colorScheme.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              try {
                final authService = AuthService();
                await authService.logout();
                if (!mounted) return;
                context.goNamed('AdminAccessPage');
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al cerrar sesión: $e')),
                );
              }
            },
          ),
        ],
      ),
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          // Contenido principal
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!))
                    : organizations.isEmpty
                        ? const Center(
                            child: Text('No hay organizaciones para mostrar'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: organizations.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final org = organizations[index];
                              return Card(
                                elevation: 2,
                                color: colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  onTap: () => _handleOrganizationTap(org),
                                  leading: org['logoUrl'] != null &&
                                          org['logoUrl'].toString().isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            org['logoUrl'],
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: colorScheme.secondary
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.business,
                                                  color: colorScheme.secondary,
                                                  size: 24,
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: colorScheme.secondary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.business,
                                            color: colorScheme.secondary,
                                            size: 24,
                                          ),
                                        ),
                                  title: Text(
                                    org['name'] ?? 'Sin nombre',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  subtitle: org['description'] != null
                                      ? Text(org['description'],
                                          style: TextStyle(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.7)))
                                      : null,
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        onPressed: () async {
          final result = await showModalBottomSheet<String>(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.add_business,
                          color: colorScheme.secondary),
                      title: const Text('Crear organización'),
                      onTap: () {
                        Navigator.of(context).pop('create');
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.group_add, color: colorScheme.secondary),
                      title: const Text('Unirse a una organización'),
                      onTap: () {
                        Navigator.of(context).pop('join');
                      },
                    ),
                  ],
                ),
              );
            },
          );
          if (result == 'create') {
            context.goNamed('CreateOrganization');
          } else if (result == 'join') {
            _showJoinDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
