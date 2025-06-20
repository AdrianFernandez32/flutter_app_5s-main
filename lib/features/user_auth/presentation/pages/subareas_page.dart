import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'questionnaire_page.dart';
import 'package:flutter_app_5s/auth/auth_service.dart';
import 'audits_page.dart';

class SubareasPage extends StatefulWidget {
  final int orgId;
  final int areaId;
  final String areaName;
  final bool modoHistorico;

  const SubareasPage({
    Key? key,
    required this.orgId,
    required this.areaId,
    required this.areaName,
    this.modoHistorico = false,
  }) : super(key: key);

  @override
  State<SubareasPage> createState() => _SubareasPageState();
}

class _SubareasPageState extends State<SubareasPage> {
  late Future<List<Map<String, dynamic>>> _subareasFuture;

  @override
  void initState() {
    super.initState();
    _subareasFuture = _fetchSubareas();
  }

  Future<List<Map<String, dynamic>>> _fetchSubareas() async {
    final authService = AuthService();
    final accessToken = authService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('No has iniciado sesión.');
    }
    final response = await http.get(
      Uri.parse(
          'https://djnxv2fqbiqog.cloudfront.net/org/${widget.orgId}/area/${widget.areaId}/subarea'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('=== Subareas Information ===');
      for (var subarea in data) {
        print('Subarea ID: ${subarea['id']}, Name: ${subarea['name']}');
      }
      print('========================');
      return data
          .map((subarea) => {
                'id': subarea['id'].toString(),
                'name': subarea['name'] ?? '',
              })
          .toList();
    } else {
      throw Exception('Error al cargar subáreas: ${response.statusCode}');
    }
  }

  Future<void> _showCreateSubareaDialog() async {
    final nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear nueva subárea'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              try {
                final authService = AuthService();
                final accessToken = authService.accessToken;
                if (accessToken == null || accessToken.isEmpty) {
                  throw Exception('No has iniciado sesión.');
                }
                final response = await http.post(
                  Uri.parse(
                      'https://djnxv2fqbiqog.cloudfront.net/org/${widget.orgId}/area/${widget.areaId}/subarea'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $accessToken',
                  },
                  body: jsonEncode({
                    'name': nameController.text,
                  }),
                );
                if (response.statusCode == 201 || response.statusCode == 200) {
                  Navigator.of(context).pop();
                  setState(() {
                    _subareasFuture = _fetchSubareas();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Error al crear subárea: \\${response.statusCode}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: colorScheme.secondary,
        title: Text(
          'Subáreas de ${widget.areaName}',
          style: const TextStyle(color: Colors.white, fontSize: 32),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Container(
            color: const Color.fromRGBO(134, 75, 111, 1),
            height: 2,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _subareasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No subáreas found'));
          }
          final subareas = snapshot.data!;
          return ListView.builder(
            itemCount: subareas.length,
            itemBuilder: (context, i) {
              IconData icon;
              if (i == 0) {
                icon = Icons.layers;
              } else if (i == 1) {
                icon = Icons.category;
              } else {
                icon = Icons.dashboard;
              }
              return GestureDetector(
                onTap: () async {
                  final subareaId = subareas[i]['id'];
                  final subareaName = subareas[i]['name'];
                  if (widget.modoHistorico) {
                    // Navega a AuditsPage (histórico y en proceso)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuditsPage(
                          subareaId: int.tryParse(subareaId) ?? 0,
                          subareaName: subareaName,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  } else {
                    final authService = AuthService();
                    final accessToken = authService.accessToken;
                    if (accessToken == null || accessToken.isEmpty) {
                      throw Exception('No has iniciado sesión.');
                    }

                    // Verificar si hay una auditoría activa
                    final auditResp = await http.get(
                      Uri.parse(
                          'https://djnxv2fqbiqog.cloudfront.net/audit/subarea/$subareaId/active'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $accessToken',
                      },
                    );

                    if (auditResp.statusCode == 200) {
                      final List<dynamic> audits = json.decode(auditResp.body);
                      if (audits.isNotEmpty) {
                        final auditId = audits[0]['id'];
                        // Mostrar loading mientras se obtiene el cuestionario
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        final fullAuditResp = await http.get(
                          Uri.parse(
                              'https://djnxv2fqbiqog.cloudfront.net/audit/$auditId/full'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer $accessToken',
                          },
                        );
                        if (!mounted) return;
                        Navigator.of(context).pop(); // Cierra el loading
                        if (fullAuditResp.statusCode == 200) {
                          final auditData = json.decode(fullAuditResp.body);
                          // Navigate to SSelectionPage with auditData
                          context.pushNamed(
                            'SSelection',
                            extra: {
                              'auditData': auditData,
                              'subareaId': int.parse(subareaId.toString()),
                              'subareaName': subareaName,
                            },
                          );
                        } else {
                          _showErrorDialog(
                              context, 'No se pudo obtener el cuestionario.');
                        }
                        return;
                      }
                    }

                    // Si no hay auditoría activa, preguntar al usuario si desea crear una nueva
                    final shouldCreate = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('No hay auditoría activa'),
                        content: const Text(
                            '¿Deseas iniciar una nueva auditoría para esta subárea?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Crear auditoría'),
                          ),
                        ],
                      ),
                    );

                    if (shouldCreate == true) {
                      // Mostrar loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );
                      try {
                        final createAuditResp = await http.post(
                          Uri.parse(
                              'https://djnxv2fqbiqog.cloudfront.net/audit/subarea/$subareaId'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer $accessToken',
                          },
                        );
                        if (!mounted) return;
                        Navigator.of(context).pop(); // Cierra el loading
                        // Debug info
                        print('Status code: \\${createAuditResp.statusCode}');
                        print('Response body: \\${createAuditResp.body}');
                        if (createAuditResp.statusCode == 201 ||
                            createAuditResp.statusCode == 200) {
                          final body = createAuditResp.body.trim();
                          if (body.isNotEmpty) {
                            final auditData = json.decode(body);
                            if (auditData != null &&
                                auditData is Map<String, dynamic>) {
                              context.pushNamed(
                                'SSelection',
                                extra: {
                                  'auditData': auditData,
                                  'subareaId': int.parse(subareaId.toString()),
                                  'subareaName': subareaName,
                                },
                              );
                            } else {
                              _showErrorDialog(context,
                                  'La auditoría fue creada pero la respuesta es inválida.');
                            }
                          } else {
                            // El body está vacío, obtener la auditoría activa
                            final auditResp = await http.get(
                              Uri.parse(
                                  'https://djnxv2fqbiqog.cloudfront.net/audit/subarea/$subareaId/active'),
                              headers: {
                                'Content-Type': 'application/json',
                                'Authorization': 'Bearer $accessToken',
                              },
                            );
                            if (auditResp.statusCode == 200) {
                              final List<dynamic> audits =
                                  json.decode(auditResp.body);
                              if (audits.isNotEmpty) {
                                final auditId = audits[0]['id'];
                                // Obtener el cuestionario completo
                                final fullAuditResp = await http.get(
                                  Uri.parse(
                                      'https://djnxv2fqbiqog.cloudfront.net/audit/$auditId/full'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Bearer $accessToken',
                                  },
                                );
                                if (fullAuditResp.statusCode == 200) {
                                  final auditData =
                                      json.decode(fullAuditResp.body);
                                  context.pushNamed(
                                    'SSelection',
                                    extra: {
                                      'auditData': auditData,
                                      'subareaId':
                                          int.parse(subareaId.toString()),
                                      'subareaName': subareaName,
                                    },
                                  );
                                } else {
                                  _showErrorDialog(context,
                                      'No se pudo obtener el cuestionario de la auditoría recién creada.');
                                }
                              } else {
                                _showErrorDialog(context,
                                    'No se encontró la auditoría recién creada.');
                              }
                            } else {
                              _showErrorDialog(context,
                                  'No se pudo obtener la auditoría recién creada.');
                            }
                          }
                        } else {
                          String errorMsg = 'No se pudo crear la auditoría.';
                          try {
                            final errorBody = json.decode(createAuditResp.body);
                            if (errorBody is Map &&
                                errorBody['message'] != null) {
                              errorMsg = errorBody['message'];
                            }
                          } catch (_) {}
                          _showErrorDialog(context, errorMsg);
                        }
                      } catch (e) {
                        if (!mounted) return;
                        Navigator.of(context).pop(); // Cierra el loading
                        _showErrorDialog(context, 'Error de red: $e');
                      }
                    }
                  }
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(214, 231, 239, 1),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(0xFF1487D4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subareas[i]['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.blue, size: 32),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSubareaDialog,
        child: const Icon(Icons.add),
        tooltip: 'Crear subárea',
      ),
    );
  }

  // Helper to show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
