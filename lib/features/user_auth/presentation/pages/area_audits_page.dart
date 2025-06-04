import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_5s/auth/auth_service.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/statistics_audit_page.dart';

class AreaAuditsPage extends StatefulWidget {
  final int areaId;
  final String areaName;
  final Color color;
  const AreaAuditsPage({
    Key? key,
    required this.areaId,
    required this.areaName,
    required this.color,
  }) : super(key: key);

  @override
  State<AreaAuditsPage> createState() => _AreaAuditsPageState();
}

class _AreaAuditsPageState extends State<AreaAuditsPage> {
  late Future<List<Map<String, dynamic>>> _auditsFuture;

  @override
  void initState() {
    super.initState();
    _auditsFuture = _fetchAreaAudits();
  }

  Future<List<Map<String, dynamic>>> _fetchAreaAudits() async {
    final authService = AuthService();
    final accessToken = authService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('No has iniciado sesión.');
    }
    final response = await http.get(
      Uri.parse(
          'https://djnxv2fqbiqog.cloudfront.net/audit/area/${widget.areaId}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<Map<String, dynamic>> audits = [];
      for (final subarea in data['subareas'] ?? []) {
        for (final audit in subarea['audits'] ?? []) {
          audits.add({
            ...audit,
            'subareaName': subarea['name'],
          });
        }
      }
      // Ordenar por fecha descendente
      audits.sort((a, b) {
        final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });
      return audits;
    } else {
      throw Exception('Error al obtener auditorías: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color,
        title: Text(widget.areaName, style: const TextStyle(fontSize: 26)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: const Color.fromRGBO(134, 75, 111, 1),
            height: 2,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _auditsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No hay auditorías para esta área.'));
          }
          final audits = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: audits.length,
            itemBuilder: (context, i) {
              final audit = audits[i];
              final isComplete =
                  audit['status'] == 1 || audit['closed'] == true;
              final date = audit['createdAt'] != null
                  ? DateTime.tryParse(audit['createdAt'])
                  : null;
              final formattedDate = date != null
                  ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}"
                  : "Sin fecha";
              final score = isComplete &&
                      audit['questionsAnswered'] != null &&
                      audit['totalQuestions'] != null &&
                      audit['totalQuestions'] > 0
                  ? ((audit['questionsAnswered'] / audit['totalQuestions']) *
                          100)
                      .round()
                  : null;
              return GestureDetector(
                onTap: isComplete
                    ? () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        try {
                          final authService = AuthService();
                          final accessToken = authService.accessToken;
                          final auditId = audit['id'];
                          final response = await http.get(
                            Uri.parse(
                                'https://djnxv2fqbiqog.cloudfront.net/audit/$auditId/full'),
                            headers: {
                              'Authorization': 'Bearer $accessToken',
                            },
                          );
                          Navigator.of(context).pop(); // Quitar loader
                          if (response.statusCode == 200) {
                            final fullAudit = jsonDecode(
                              utf8.decode(response.bodyBytes),
                            );
                            // Calcular s_scores y score si no existen
                            if (fullAudit['auditCategories'] != null) {
                              final categories =
                                  fullAudit['auditCategories'] as List<dynamic>;
                              final sKeys = ['S1', 'S2', 'S3', 'S4', 'S5'];
                              Map<String, double> sScores = {};
                              double totalScore = 0;
                              int totalQuestions = 0;
                              for (final sKey in sKeys) {
                                final cat = categories.firstWhere(
                                  (c) => c['scategory'] == sKey,
                                  orElse: () => null,
                                );
                                if (cat != null &&
                                    cat['auditQuestions'] != null) {
                                  int sAnswered = 0;
                                  int sTotal = 0;
                                  double sSum = 0;
                                  for (final q in cat['auditQuestions']) {
                                    final items =
                                        q['items'] as List<dynamic>? ?? [];
                                    if (items.isEmpty) {
                                      sTotal++;
                                      final ans = q['auditAnswer'];
                                      if (ans != null &&
                                          ans['score'] != null &&
                                          ans['score'] >= 0) {
                                        sAnswered++;
                                        sSum +=
                                            (ans['score'] as num).toDouble();
                                      }
                                    } else {
                                      for (final item in items) {
                                        sTotal++;
                                        final ans = item['auditAnswer'];
                                        if (ans != null &&
                                            ans['score'] != null &&
                                            ans['score'] >= 0) {
                                          sAnswered++;
                                          sSum +=
                                              (ans['score'] as num).toDouble();
                                        }
                                      }
                                    }
                                  }
                                  final sScore = (sTotal > 0)
                                      ? (sSum / (sTotal * 5) * 100)
                                      : 0.0;
                                  sScores[sKey] = sScore;
                                  totalScore += sSum;
                                  totalQuestions += sTotal;
                                } else {
                                  sScores[sKey] = 0.0;
                                }
                              }
                              fullAudit['s_scores'] = sScores;
                              fullAudit['score'] = (totalQuestions > 0)
                                  ? (totalScore / totalQuestions) * 100
                                  : 0.0;
                              // Asegura que el areaId esté presente para la navegación de regreso
                              fullAudit['areaId'] = widget.areaId;
                              // Asegura que createdAt esté presente en fullAudit
                              if (fullAudit['createdAt'] == null &&
                                  audit['createdAt'] != null) {
                                fullAudit['createdAt'] = audit['createdAt'];
                              }
                            }
                            // Filtrar las últimas 6 auditorías de la misma subárea
                            final subareaAudits = audits
                                .where((a) =>
                                    a['subareaName'] == audit['subareaName'])
                                .toList();
                            subareaAudits.sort((a, b) {
                              final aDate =
                                  DateTime.tryParse(a['createdAt'] ?? '') ??
                                      DateTime(1970);
                              final bDate =
                                  DateTime.tryParse(b['createdAt'] ?? '') ??
                                      DateTime(1970);
                              return bDate.compareTo(aDate);
                            });
                            final last6 = subareaAudits.take(6).toList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StatisticsAuditPage(
                                  zona: audit['subareaName'] ?? '',
                                  auditDate: formattedDate,
                                  area: widget.areaName,
                                  color: widget.color,
                                  historicAudits: last6,
                                  selectedAudit: fullAudit,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error al obtener detalles: ${response.statusCode}')),
                            );
                          }
                        } catch (e) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isComplete ? Colors.transparent : Colors.blue,
                      width: isComplete ? 0 : 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_bar,
                            size: 32, color: Colors.black54),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              audit['subareaName'] ?? '',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isComplete ? 'Completada' : 'Incompleta',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isComplete ? Colors.black87 : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      isComplete
                          ? Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: score != null && score >= 70
                                    ? Colors.green[200]
                                    : Colors.red[400],
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                score != null ? score.toString() : '',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            )
                          : const Text(
                              'N/A',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black38),
                            ),
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
}
