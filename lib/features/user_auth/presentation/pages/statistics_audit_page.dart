import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/bar_chart.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/radar_chart.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/areas_page.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_app_5s/auth/auth_service.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/area_audits_page.dart';

class StatisticsAuditPage extends StatelessWidget {
  final String zona;
  final String auditDate;
  final String area;
  final Color color;
  final List<dynamic> historicAudits;
  final dynamic selectedAudit;

  const StatisticsAuditPage({
    Key? key,
    required this.zona,
    required this.auditDate,
    required this.area,
    required this.color,
    required this.historicAudits,
    required this.selectedAudit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuditViewExample(
      zona: zona,
      auditDate: auditDate,
      area: area,
      color: color,
      historicAudits: historicAudits,
      selectedAudit: selectedAudit,
    );
  }
}

class AuditViewExample extends StatelessWidget {
  final String zona;
  final String auditDate;
  final String area;
  final Color color;
  final List<dynamic> historicAudits;
  final dynamic selectedAudit;

  const AuditViewExample({
    Key? key,
    required this.zona,
    required this.auditDate,
    required this.area,
    required this.color,
    required this.historicAudits,
    required this.selectedAudit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: color,
          title: Text(
            zona,
            style: const TextStyle(color: Colors.white, fontSize: 32),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 33,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.download, color: Colors.white, size: 32),
                tooltip: 'Descargar Excel',
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  try {
                    final auditId =
                        selectedAudit != null ? selectedAudit['id'] : null;
                    if (auditId == null) {
                      scaffoldMessenger.showSnackBar(const SnackBar(
                          content: Text('No hay auditoría seleccionada.')));
                      return;
                    }
                    scaffoldMessenger.showSnackBar(const SnackBar(
                        content: Text('Descargando archivo...')));
                    // Obtener token de autenticación
                    final authService = AuthService();
                    final accessToken = authService.accessToken;
                    if (accessToken == null || accessToken.isEmpty) {
                      scaffoldMessenger.showSnackBar(const SnackBar(
                          content: Text('No has iniciado sesión.')));
                      return;
                    }
                    final url = Uri.parse(
                        'https://djnxv2fqbiqog.cloudfront.net/reportes/$auditId');
                    final response = await http.get(url,
                        headers: {'Authorization': 'Bearer $accessToken'});
                    if (response.statusCode == 200) {
                      final bytes = response.bodyBytes;
                      final tempDir = await getTemporaryDirectory();
                      final filePath =
                          '${tempDir.path}/auditoria_$auditId.xlsx';
                      final file = File(filePath);
                      await file.writeAsBytes(bytes);
                      if (Platform.isAndroid) {
                        await OpenFile.open(filePath);
                        scaffoldMessenger.showSnackBar(const SnackBar(
                            content: Text('Archivo descargado y abierto.')));
                      } else if (Platform.isIOS) {
                        await Share.shareXFiles([
                          XFile(filePath,
                              mimeType:
                                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
                        ]);
                        scaffoldMessenger.showSnackBar(const SnackBar(
                            content: Text(
                                'Archivo descargado. Usa compartir para guardarlo en Archivos.')));
                      } else {
                        scaffoldMessenger.showSnackBar(const SnackBar(
                            content: Text(
                                'Archivo descargado correctamente. Revisa tu carpeta de archivos.')));
                      }
                    } else {
                      scaffoldMessenger.showSnackBar(SnackBar(
                          content: Text(
                              'Error al descargar: ${response.statusCode}')));
                    }
                  } catch (e) {
                    scaffoldMessenger
                        .showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(10),
            child: Container(
              color: const Color.fromRGBO(134, 75, 111, 1),
              height: 2,
            ),
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: const TabBar(
                    tabs: [
                      Tab(text: "Radial"),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            child: AuditViewState(
              historicAudits: historicAudits,
              selectedAudit: selectedAudit,
            ),
          ),
        ),
      ),
    );
  }
}

class AuditViewState extends StatelessWidget {
  final List<dynamic> historicAudits;
  final dynamic selectedAudit;

  const AuditViewState(
      {Key? key, required this.historicAudits, required this.selectedAudit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tomar las últimas 6 auditorías (incluyendo la seleccionada)
    List<dynamic> audits;
    if (historicAudits.isEmpty && selectedAudit != null) {
      audits = [selectedAudit];
    } else if (historicAudits.length > 6) {
      audits = historicAudits.sublist(historicAudits.length - 6);
    } else {
      audits = historicAudits;
    }
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 2.6,
          child: TabBarView(
            children: [
              AspectRatio(
                aspectRatio: 1.5,
                child: RadarChartWidget(
                  audits: audits,
                  selectedAudit: selectedAudit,
                ),
              ),
            ],
          ),
        ),
        // Mostrar listado de S
        if (selectedAudit != null && selectedAudit['auditCategories'] != null)
          ..._buildSList(context, selectedAudit),
      ],
    );
  }

  List<Widget> _buildSList(BuildContext context, dynamic audit) {
    final categories = audit['auditCategories'] as List<dynamic>? ?? [];
    final sOrder = ['S1', 'S2', 'S3', 'S4', 'S5'];
    final sNames = [
      'SEIRI',
      'SEITON',
      'SEISON',
      'SEIKETSU',
      'SHITSUKE',
    ];
    List<Widget> widgets = [];
    for (int i = 0; i < 5; i++) {
      final sKey = sOrder[i];
      final sName = sNames[i];
      final cat = categories.firstWhere(
        (c) => c['scategory'] == sKey,
        orElse: () => null,
      );
      final value = cat != null &&
              cat['questionsAnswered'] != null &&
              cat['totalQuestions'] != null &&
              cat['totalQuestions'] > 0
          ? ((cat['questionsAnswered'] / cat['totalQuestions']) * 100).round()
          : 0;
      widgets.add(
        GestureDetector(
          onTap: cat != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SDetailPage(
                        sName: sName,
                        sKey: sKey,
                        category: cat,
                      ),
                    ),
                  );
                }
              : null,
          child: SWidget(
            index: i + 1,
            name: sName,
            value: value,
          ),
        ),
      );
      if (i < 4) widgets.add(const SizedBox(height: 16));
    }
    return widgets;
  }
}

class SDetailPage extends StatelessWidget {
  final String sName;
  final String sKey;
  final dynamic category;

  const SDetailPage({
    Key? key,
    required this.sName,
    required this.sKey,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final questions = category['auditQuestions'] as List<dynamic>? ?? [];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF1487D4),
        title: Text('$sKey $sName',
            style: const TextStyle(color: Colors.white, fontSize: 32)),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 33,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Container(
            color: const Color.fromRGBO(134, 75, 111, 1),
            height: 2,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, i) {
          final q = questions[i];
          final items = q['items'] as List<dynamic>? ?? [];
          if (items.isEmpty) {
            return _buildQuestionCard(q, null);
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  items.map((item) => _buildQuestionCard(q, item)).toList(),
            );
          }
        },
      ),
    );
  }

  Widget _buildQuestionCard(dynamic q, dynamic item) {
    final questionText = q['question'] ?? '';
    final answer = item != null ? item['auditAnswer'] : q['auditAnswer'];
    final itemLabel = item != null ? (item['item'] ?? '') : '';
    final score = answer != null ? answer['score'] : null;
    final notes = answer != null ? answer['notes'] : null;
    final imageUrl = answer != null ? answer['imageUrl'] : null;
    Color scoreColor;
    if (score == null) {
      scoreColor = Colors.grey;
    } else if (score < 3) {
      scoreColor = const Color(0xFFD22222); // rojo
    } else if (score < 5) {
      scoreColor = const Color(0xFFFFA726); // naranja
    } else {
      scoreColor = const Color(0xFF4CAF50); // verde
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (itemLabel.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E6F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.label_important,
                        size: 20, color: Color(0xFF864B6F)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        itemLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF864B6F)),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            Text(questionText,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            if (score != null)
              Row(
                children: [
                  Icon(Icons.check_circle, color: scoreColor, size: 22),
                  const SizedBox(width: 8),
                  Text('Respuesta: ',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  Flexible(
                    child: Text(
                      '$score',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                          fontSize: 16),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            if (notes != null && notes.toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.comment, color: Colors.black45, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Comentario: $notes',
                        style: const TextStyle(
                            color: Colors.black54, fontStyle: FontStyle.italic),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            if (imageUrl != null && imageUrl.toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image,
                          size: 40, color: Colors.grey),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 140,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SWidget extends StatelessWidget {
  final int index;
  final String name;
  final int value;

  const SWidget({
    Key? key,
    required this.index,
    required this.name,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: _getProgressColor(value),
            ),
            height: 80,
            margin: const EdgeInsets.only(left: 15),
            child: Row(
              children: [
                const SizedBox(width: 75),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: SizedBox()),
                      Text(
                        "$name - $value",
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      LinearProgressIndicator(
                        value: value / 100,
                        color: _getProgressBarColor(value),
                        backgroundColor: Colors.white,
                        minHeight: 6.0,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    context.goNamed('Menu');
                  },
                  iconSize: 50.0,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildSIcon("${index}S"),
          ),
        ],
      ),
    );
  }

  Widget _buildSIcon(String label) {
    return Container(
      width: 80.0,
      height: 80.0,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(134, 75, 111, 1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 50.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress < 50) {
      return const Color.fromRGBO(255, 180, 171, 1);
    } else if (progress < 80) {
      return const Color.fromRGBO(255, 220, 193, 1);
    } else {
      return const Color.fromRGBO(174, 242, 197, 1);
    }
  }

  Color _getProgressBarColor(int progress) {
    if (progress < 50) {
      return const Color.fromARGB(255, 208, 34, 34);
    } else if (progress < 80) {
      return const Color.fromARGB(255, 195, 107, 41);
    } else {
      return const Color.fromARGB(255, 25, 187, 79);
    }
  }
}
