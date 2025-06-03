import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app_5s/auth/auth_service.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/scheduler.dart';

class SSelectionPage extends StatefulWidget {
  final Map<String, dynamic> auditData;
  final int subareaId;
  final String subareaName;

  const SSelectionPage({
    Key? key,
    required this.auditData,
    required this.subareaId,
    required this.subareaName,
  }) : super(key: key);

  @override
  State<SSelectionPage> createState() => _SSelectionPageState();
}

class _SSelectionPageState extends State<SSelectionPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, dynamic>> _sList = [];
  String? _error;
  double _totalProgress = 0.0;
  int _totalPercent = 0;
  late int _auditId;
  Map<String, dynamic> _auditData = {};

  @override
  void initState() {
    super.initState();
    _auditData = widget.auditData;
    _auditId = widget.auditData['id'] is int
        ? widget.auditData['id']
        : int.tryParse(widget.auditData['id'].toString()) ?? 0;
    _loadProgressFromAuditData();
  }

  Future<void> _refreshAuditData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final authService = AuthService();
      final accessToken = authService.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No has iniciado sesión.');
      }
      final response = await http.get(
        Uri.parse('https://djnxv2fqbiqog.cloudfront.net/audit/$_auditId/full'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Error al recargar auditoría: ${response.statusCode}');
      }
      _auditData = json.decode(response.body);
      _loadProgressFromAuditData();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _loadProgressFromAuditData() {
    try {
      final auditCategories =
          _auditData['auditCategories'] as List<dynamic>? ?? [];
      final Map<String, List<dynamic>> sQuestions = {};
      int totalQuestions = 0;
      int answeredQuestions = 0;
      for (var cat in auditCategories) {
        final sCategory = cat['scategory'] ?? 'S1';
        if (!sQuestions.containsKey(sCategory)) {
          sQuestions[sCategory] = [];
        }
        final questions = cat['auditQuestions'] as List<dynamic>? ?? [];
        for (var q in questions) {
          sQuestions[sCategory]!.add(q);
          final items = q['items'] as List<dynamic>? ?? [];
          if (items.isEmpty) {
            totalQuestions++;
            if (q['auditAnswer'] != null) {
              answeredQuestions++;
            }
          } else {
            for (var item in items) {
              totalQuestions++;
              if (item['auditAnswer'] != null) {
                answeredQuestions++;
              }
            }
          }
        }
      }
      _sList = [];
      for (var s in ['S1', 'S2', 'S3', 'S4', 'S5']) {
        final questions = sQuestions[s] ?? [];
        int sTotal = 0;
        int sAnswered = 0;
        for (var q in questions) {
          final items = q['items'] as List<dynamic>? ?? [];
          if (items.isEmpty) {
            sTotal++;
            if (q['auditAnswer'] != null) {
              sAnswered++;
            }
          } else {
            for (var item in items) {
              sTotal++;
              if (item['auditAnswer'] != null) {
                sAnswered++;
              }
            }
          }
        }
        _sList.add({
          'title': s,
          'description': _getSDescription(s),
          'progress': sTotal > 0 ? sAnswered / sTotal : 0.0,
          'totalQuestions': sTotal,
          'answeredQuestions': sAnswered,
        });
      }
      _totalProgress =
          totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;
      _totalPercent = (_totalProgress * 100).round();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getSDescription(String s) {
    switch (s) {
      case 'S1':
        return 'SEIRI - Clasificación';
      case 'S2':
        return 'SEITON - Orden';
      case 'S3':
        return 'SEISO - Limpieza';
      case 'S4':
        return 'SEIKETSU - Estandarización';
      case 'S5':
        return 'SHITSUKE - Disciplina';
      default:
        return '';
    }
  }

  Future<void> _saveAndFinish() async {
    setState(() => _isSaving = true);

    try {
      final authService = AuthService();
      final accessToken = authService.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No has iniciado sesión.');
      }

      // Complete the audit
      final response = await http.put(
        Uri.parse(
            'https://djnxv2fqbiqog.cloudfront.net/audit/complete/${_auditData['id']}'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al finalizar auditoría: ${response.statusCode}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auditoría finalizada exitosamente')),
        );
        context.goNamed('Menu');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _goToQuestionnaire(Map<String, dynamic> s) async {
    await context.pushNamed(
      'Cuestionario',
      extra: {
        'auditData': _auditData,
        'selectedS': s['title'],
        'subareaId': widget.subareaId,
        'subareaName': widget.subareaName,
      },
    );
    await _refreshAuditData();
  }

  int _calculateProgressForS(String s) {
    int totalQuestions = 0;
    int answeredQuestions = 0;
    final auditCategories =
        widget.auditData['auditCategories'] as List<dynamic>? ?? [];
    final filteredCategories =
        auditCategories.where((cat) => cat['scategory'] == s).toList();
    for (var cat in filteredCategories) {
      final qs = cat['auditQuestions'] as List<dynamic>? ?? [];
      for (var q in qs) {
        final items = q['items'] as List<dynamic>? ?? [];
        if (items.isEmpty) {
          totalQuestions++;
          if (q['auditAnswer'] != null) {
            answeredQuestions++;
          }
        } else {
          for (var item in items) {
            totalQuestions++;
            if (item['auditAnswer'] != null) {
              answeredQuestions++;
            }
          }
        }
      }
    }
    return totalQuestions > 0 ? (answeredQuestions * 100 ~/ totalQuestions) : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProgressFromAuditData,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    bool allComplete = _sList.every((s) => s['progress'] == 1.0);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          toolbarHeight: 80,
          title: const Text(
            'Selecciona una S',
            style: TextStyle(color: Colors.white, fontSize: 32),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(10),
            child: Container(
              color: const Color.fromRGBO(134, 75, 111, 1),
              height: 2,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 14.0,
                percent: _totalProgress,
                animation: true,
                animationDuration: 800,
                center: Text(
                  '$_totalPercent%',
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown),
                ),
                progressColor:
                    _totalProgress == 1.0 ? Colors.green : Colors.blue,
                backgroundColor: Colors.grey[300]!,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshAuditData,
                child: ListView.separated(
                  itemCount: _sList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final s = _sList[index];
                    return Card(
                      elevation: 2,
                      color: const Color(0xFFF5F7FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        onTap: () => _goToQuestionnaire(s),
                        leading: CircleAvatar(
                          radius: 32,
                          child: Text(
                            s['title'],
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        title: Text(
                          '${s['title']} ${s['description']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            LinearPercentIndicator(
                              lineHeight: 8.0,
                              percent: s['progress'],
                              backgroundColor: Colors.grey[200]!,
                              progressColor: Colors.blue,
                              barRadius: const Radius.circular(8),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${s['answeredQuestions']}/${s['totalQuestions']} preguntas respondidas',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.black54),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: allComplete
          ? FloatingActionButton.extended(
              onPressed: _isSaving ? null : _saveAndFinish,
              backgroundColor: Colors.green,
              icon: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(Icons.check),
              label: const Text('Finalizar'),
            )
          : null,
    );
  }
}
