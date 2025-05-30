import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app_5s/auth/auth_service.dart';
import 'package:flutter/rendering.dart';

class OrganizationsListPage extends StatefulWidget {
  const OrganizationsListPage({Key? key}) : super(key: key);

  @override
  State<OrganizationsListPage> createState() => _OrganizationsListPageState();
}

class _OrganizationsListPageState extends State<OrganizationsListPage> {
  List<dynamic> organizations = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchOrganizations();
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
      ),
      backgroundColor: colorScheme.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : organizations.isEmpty
                  ? const Center(
                      child: Text('No hay organizaciones para mostrar'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: organizations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final org = organizations[index];
                        return Card(
                          elevation: 2,
                          color: colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            onTap: () {
                              final authService = AuthService();
                              if (org['name']?.toString().toLowerCase() ==
                                  'admin') {
                                context.goNamed('AdminAccessPage');
                              } else {
                                authService.organizationId =
                                    org['id']?.toString();
                                context.goNamed('Menu');
                              }
                            },
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
