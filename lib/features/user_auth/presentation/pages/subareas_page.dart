import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'questionnaire_page.dart';

class SubareasPage extends StatefulWidget {
  final int orgId;
  final int areaId;
  final String areaName;

  const SubareasPage({
    Key? key,
    required this.orgId,
    required this.areaId,
    required this.areaName,
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
    final response = await http.get(
      Uri.parse(
          'https://djnxv2fqbiqog.cloudfront.net/org/${widget.orgId}/area/${widget.areaId}/subarea'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subáreas de ${widget.areaName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                  try {
                    // Fetch active audits for this subarea
                    final auditResp = await http.get(
                      Uri.parse(
                          'https://djnxv2fqbiqog.cloudfront.net/audit/subarea/$subareaId/active'),
                      headers: {'Content-Type': 'application/json'},
                    );
                    if (auditResp.statusCode == 200) {
                      final List<dynamic> audits = json.decode(auditResp.body);
                      if (audits.isNotEmpty) {
                        final auditId = audits[0]['id'];
                        // Fetch full audit info
                        final fullAuditResp = await http.get(
                          Uri.parse(
                              'https://djnxv2fqbiqog.cloudfront.net/audit/$auditId/full'),
                          headers: {'Content-Type': 'application/json'},
                        );
                        if (fullAuditResp.statusCode == 200) {
                          final auditData = json.decode(fullAuditResp.body);
                          // Navigate to QuestionnairePage with auditData
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionnairePage(
                                auditData: auditData,
                              ),
                            ),
                          );
                        } else {
                          _showErrorDialog(
                              context, 'No se pudo obtener el cuestionario.');
                        }
                      } else {
                        _showErrorDialog(context,
                            'No hay auditoría activa para esta subárea.');
                      }
                    } else {
                      _showErrorDialog(
                          context, 'Error al buscar auditoría activa.');
                    }
                  } catch (e) {
                    _showErrorDialog(context, 'Error de red: $e');
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
                      Icon(icon, size: 40, color: Colors.black87),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Text(
                          subareas[i]['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.blue, size: 28),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
