import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app_5s/auth/auth_service.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/main_menu.dart';

class QuestionnairePage extends StatefulWidget {
  final Map<String, dynamic> auditData;
  const QuestionnairePage({Key? key, required this.auditData})
      : super(key: key);

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage>
    with TickerProviderStateMixin {
  Map<String, List<Map<String, dynamic>>> sCategoriesMap = {};
  List<String> sOrder = [];
  int currentSIndex = 0;
  int currentQuestionIndex = 0;
  TabController? _questionTabController;

  // Mapa para guardar respuestas: questionId -> { 'score': int, 'comment': String, 'itemId': int }
  Map<int, Map<String, dynamic>> respuestas = {};

  @override
  void initState() {
    super.initState();
    // Agrupa las preguntas por scategory
    final auditCategories =
        widget.auditData['auditCategories'] as List<dynamic>? ?? [];
    for (var cat in auditCategories) {
      final sCat = cat['scategory'] ?? 'S1';
      if (!sCategoriesMap.containsKey(sCat)) {
        sCategoriesMap[sCat] = [];
      }
      final questions = cat['auditQuestions'] as List<dynamic>? ?? [];
      for (var q in questions) {
        sCategoriesMap[sCat]!.add({
          'category': cat,
          'question': q,
        });
        // Precargar respuestas previas si existen
        final questionId =
            q['id'] is int ? q['id'] : int.tryParse(q['id'].toString()) ?? 0;
        if (q['items'] != null) {
          for (var item in q['items']) {
            if (item['auditAnswer'] != null) {
              respuestas[questionId] = {
                'score': item['auditAnswer']['score'],
                'comment': item['auditAnswer']['notes'],
              };
              break; // Solo toma la primera respuesta encontrada por pregunta
            }
          }
        }
      }
    }
    sOrder = sCategoriesMap.keys.toList()..sort();
    _initQuestionTabController();
  }

  void _initQuestionTabController() {
    final questions = sCategoriesMap[sOrder[currentSIndex]] ?? [];
    _questionTabController?.dispose();
    _questionTabController =
        TabController(length: questions.length, vsync: this);
    _questionTabController!.addListener(() {
      setState(() {
        currentQuestionIndex = _questionTabController!.index;
      });
    });
    currentQuestionIndex = 0;
  }

  @override
  void dispose() {
    _questionTabController?.dispose();
    super.dispose();
  }

  void goToPreviousS() {
    if (currentSIndex > 0) {
      setState(() {
        currentSIndex--;
        _initQuestionTabController();
      });
    }
  }

  void goToNextS() {
    if (currentSIndex < sOrder.length - 1) {
      setState(() {
        currentSIndex++;
        _initQuestionTabController();
      });
    }
  }

  String fixEncoding(String text) {
    try {
      return utf8.decode(latin1.encode(text));
    } catch (_) {
      return text;
    }
  }

  Future<void> onGuardarPressed() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar guardado'),
          content:
              const Text('¿Estás seguro de que deseas guardar esta auditoría?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    if (confirmar == true) {
      await guardarAuditoria();
    }
  }

  Future<void> finalizarAuditoria() async {
    await guardarAuditoria(completar: true);
  }

  Future<void> guardarAuditoria({bool completar = false}) async {
    final authService = AuthService();
    final accessToken = authService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No has iniciado sesión.')),
      );
      return;
    }

    // Construir el payload para /audit/answer/batch
    final List<Map<String, dynamic>> payload = [];
    for (final entry in respuestas.entries) {
      final questionId = entry.key;
      final respuesta = entry.value;

      // Obtener la pregunta actual y sus items
      final currentCategory =
          sCategoriesMap[sOrder[currentSIndex]]?[currentQuestionIndex];
      final currentQuestion = currentCategory?['question'];
      final items = currentQuestion?['items'] as List<dynamic>? ?? [];

      // Si hay items, crear una respuesta por cada item
      if (items.isNotEmpty) {
        for (var item in items) {
          payload.add({
            'questionId': questionId,
            'score': respuesta['score'],
            'notes': respuesta['comment'] ?? '',
            'itemId': item['itemId'],
          });
        }
      } else {
        // Si no hay items, enviar solo la respuesta de la pregunta
        payload.add({
          'questionId': questionId,
          'score': respuesta['score'],
          'notes': respuesta['comment'] ?? '',
        });
      }
    }

    print('Payload a enviar:');
    print(payload);

    try {
      final response = await http.post(
        Uri.parse('https://djnxv2fqbiqog.cloudfront.net/audit/answer/batch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        if (completar) {
          // Ahora cerrar la auditoría
          final auditId = widget.auditData['id'];
          final closeResponse = await http.get(
            Uri.parse(
                'https://djnxv2fqbiqog.cloudfront.net/audit/complete/$auditId'),
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          );
          if (closeResponse.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Auditoría guardada y completada exitosamente')),
            );
            // Espera 500ms antes de navegar para evitar overlays bloqueados
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainMenu()),
                  (Route<dynamic> route) => false,
                );
              }
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Guardado OK, pero error al completar auditoría: ${closeResponse.statusCode}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Respuestas guardadas. Puedes continuar la auditoría después.')),
          );
        }
      } else {
        print('Error al guardar: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      print('Error al guardar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sOrder.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cuestionario')),
        body:
            const Center(child: Text('No hay preguntas en este cuestionario.')),
      );
    }
    final currentS = sOrder[currentSIndex];
    final questions = sCategoriesMap[currentS]!;
    final currentCat = questions[currentQuestionIndex]['category'];
    final currentQ = questions[currentQuestionIndex]['question'];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const SizedBox.shrink(),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Texto grande del S actual con fondo blanco
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 12, bottom: 0),
            child: Center(
              child: Text(
                currentS,
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Header dinámico
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.only(top: 8, bottom: 4, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  fixEncoding(currentCat['name'] ?? ''),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  fixEncoding(currentCat['description'] ?? ''),
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          TabBar(
            controller: _questionTabController,
            isScrollable: true,
            indicatorColor: const Color.fromRGBO(134, 75, 111, 1),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: List.generate(
                questions.length, (qIdx) => Tab(text: 'Pregunta ${qIdx + 1}')),
          ),
          Expanded(
            child: TabBarView(
              controller: _questionTabController,
              children: List.generate(questions.length, (qIdx) {
                final q = questions[qIdx]['question'];
                final questionId = q['id'] is int
                    ? q['id']
                    : int.tryParse(q['id'].toString()) ?? 0;
                final respuesta =
                    respuestas[questionId] ?? {'score': null, 'comment': ''};
                return SingleChildScrollView(
                  child: _QuestionView(
                    question: fixEncoding(q['question']),
                    questionId: questionId,
                    score: respuesta['score'],
                    comment: respuesta['comment'],
                    onChanged: (score, comment) {
                      setState(() {
                        respuestas[questionId] = {
                          'score': score,
                          'comment': comment,
                        };
                      });
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón Anterior S
              IconButton(
                onPressed: currentSIndex > 0 ? goToPreviousS : null,
                icon: const Icon(Icons.arrow_back, size: 32),
                color: const Color(0xFF3887C2),
                tooltip: 'Anterior S',
              ),
              // Botón Guardar
              ElevatedButton(
                onPressed: onGuardarPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  minimumSize: const Size(48, 48),
                ),
                child: const Icon(Icons.save, size: 28),
              ),
              // Botón Finalizar auditoría
              ElevatedButton(
                onPressed: finalizarAuditoria,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  minimumSize: const Size(48, 48),
                ),
                child: const Icon(Icons.check_circle, size: 28),
              ),
              // Botón Siguiente S
              IconButton(
                onPressed: currentSIndex < sOrder.length - 1 ? goToNextS : null,
                icon: const Icon(Icons.arrow_forward, size: 32),
                color: const Color(0xFF3887C2),
                tooltip: 'Siguiente S',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionView extends StatefulWidget {
  final String? question;
  final int questionId;
  final int? score;
  final String? comment;
  final void Function(int? score, String? comment) onChanged;

  const _QuestionView(
      {Key? key,
      this.question,
      required this.questionId,
      this.score,
      this.comment,
      required this.onChanged})
      : super(key: key);

  @override
  State<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<_QuestionView> {
  int? _selectedScore;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _selectedScore = widget.score;
    _commentController = TextEditingController(text: widget.comment ?? '');
    _commentController.addListener(_onCommentChanged);
  }

  @override
  void didUpdateWidget(covariant _QuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _selectedScore = widget.score;
    }
    if (oldWidget.comment != widget.comment) {
      _commentController.text = widget.comment ?? '';
    }
  }

  @override
  void dispose() {
    _commentController.removeListener(_onCommentChanged);
    _commentController.dispose();
    super.dispose();
  }

  void _onScoreChanged(int? value) {
    setState(() {
      _selectedScore = value;
    });
    widget.onChanged(_selectedScore, _commentController.text);
  }

  void _onCommentChanged() {
    widget.onChanged(_selectedScore, _commentController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(12),
        elevation: 12,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                widget.question ?? "No hay pregunta",
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 30,
              ),
              _OptionsRadios(
                value: _selectedScore,
                onChanged: _onScoreChanged,
              ),
              const SizedBox(
                height: 30,
              ),
              _CommentField(controller: _commentController),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionsRadios extends StatelessWidget {
  final int? value;
  final void Function(int?) onChanged;
  const _OptionsRadios({Key? key, this.value, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final options = [null, 0, 1, 2, 3, 4, 5];
    final labels = ["N/A", "0", "1", "2", "3", "4", "5"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(options.length, (i) {
        return Column(
          children: [
            Radio<int?>(
              value: options[i],
              groupValue: value,
              onChanged: onChanged,
            ),
            Text(labels[i],
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        );
      }),
    );
  }
}

class _CommentField extends StatelessWidget {
  final TextEditingController controller;
  const _CommentField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      margin: const EdgeInsets.only(left: 20, right: 20),
      decoration: const BoxDecoration(
          color: Color.fromRGBO(217, 217, 217, 1),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              label: Text("Comentario"),
              border: InputBorder.none,
            ),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              "0/200",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Divider(),
          Row(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add_photo_alternate_rounded)),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.sticky_note_2_outlined)),
            ],
          )
        ],
      ),
    );
  }
}
