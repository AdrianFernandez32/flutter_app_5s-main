import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app_5s/auth/auth_service.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/main_menu.dart';
import 'package:go_router/go_router.dart';

class QuestionnairePage extends StatefulWidget {
  final Map<String, dynamic> auditData;
  final String selectedS;
  final int subareaId;
  final String subareaName;

  const QuestionnairePage({
    Key? key,
    required this.auditData,
    required this.selectedS,
    required this.subareaId,
    required this.subareaName,
  }) : super(key: key);

  // Método estático para arreglar encoding
  static String fixEncodingStatic(String text) {
    try {
      return utf8.decode(latin1.encode(text));
    } catch (_) {
      return text;
    }
  }

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  List<Map<String, dynamic>> visualQuestions = [];
  int currentQuestionIndex = 0;
  Map<String, Map<String, dynamic>> respuestas = {}; // key: questionId_itemId
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _expandQuestionsForItems();
  }

  void _expandQuestionsForItems() {
    final auditCategories =
        widget.auditData['auditCategories'] as List<dynamic>? ?? [];
    final filteredCategories = auditCategories
        .where((cat) => cat['scategory'] == widget.selectedS)
        .toList();
    visualQuestions = [];
    for (var cat in filteredCategories) {
      final qs = cat['auditQuestions'] as List<dynamic>? ?? [];
      for (var q in qs) {
        final items = q['items'] as List<dynamic>? ?? [];
        if (items.isEmpty) {
          visualQuestions.add({
            'category': cat,
            'question': q,
            'item': null,
          });
          // Precargar respuesta si existe
          final questionId =
              q['id'] is int ? q['id'] : int.tryParse(q['id'].toString()) ?? 0;
          if (q['auditAnswer'] != null) {
            respuestas['${questionId}_'] = {
              'score': q['auditAnswer']['score'],
              'comment': q['auditAnswer']['notes'],
            };
          }
        } else {
          for (var item in items) {
            visualQuestions.add({
              'category': cat,
              'question': q,
              'item': item,
            });
            final questionId = q['id'] is int
                ? q['id']
                : int.tryParse(q['id'].toString()) ?? 0;
            final itemId = item['itemId'] ?? item['id'] ?? '';
            if (item['auditAnswer'] != null) {
              respuestas['${questionId}_$itemId'] = {
                'score': item['auditAnswer']['score'],
                'comment': item['auditAnswer']['notes'],
              };
            }
          }
        }
      }
    }
    setState(() {});
  }

  void _onChanged(int questionId, dynamic itemId, int? score, String? comment) {
    setState(() {
      respuestas['${questionId}_${itemId ?? ''}'] = {
        'score': score,
        'comment': comment,
      };
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _saveAnswers() async {
    setState(() => _isSaving = true);
    try {
      final authService = AuthService();
      final accessToken = authService.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No has iniciado sesión.');
      }
      final List<Map<String, dynamic>> payload = [];
      for (final entry in respuestas.entries) {
        final key = entry.key;
        final respuesta = entry.value;
        if (respuesta['score'] == null &&
            (respuesta['comment'] == null || respuesta['comment'].isEmpty)) {
          continue;
        }
        final parts = key.split('_');
        final questionId = int.tryParse(parts[0]) ?? 0;
        final itemId = parts.length > 1 && parts[1].isNotEmpty
            ? int.tryParse(parts[1])
            : null;
        if (itemId != null) {
          payload.add({
            'questionId': questionId,
            'score': respuesta['score'],
            'notes': respuesta['comment'] ?? '',
            'itemId': itemId,
          });
        } else {
          payload.add({
            'questionId': questionId,
            'score': respuesta['score'],
            'notes': respuesta['comment'] ?? '',
          });
        }
      }
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
        setState(() {
          _hasUnsavedChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Respuestas guardadas correctamente')),
        );
      } else {
        throw Exception('Error al guardar: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambios sin guardar'),
        content: const Text('Tienes cambios sin guardar. ¿Qué deseas hacer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir sin guardar'),
          ),
          TextButton(
            onPressed: () async {
              await _saveAnswers();
              Navigator.of(context).pop(true);
            },
            child: const Text('Guardar y salir'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (visualQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cuestionario')),
        body:
            const Center(child: Text('No hay preguntas en este cuestionario.')),
      );
    }
    final currentQWrap = visualQuestions[currentQuestionIndex];
    final currentCat = currentQWrap['category'];
    final currentQ = currentQWrap['question'];
    final item = currentQWrap['item'];
    final questionId = currentQ['id'] is int
        ? currentQ['id']
        : int.tryParse(currentQ['id'].toString()) ?? 0;
    final itemId = item != null ? (item['itemId'] ?? item['id'] ?? '') : null;
    final respuesta = respuestas['${questionId}_${itemId ?? ''}'] ??
        {'score': null, 'comment': ''};
    String? itemName;
    if (item != null) {
      itemName = item['item']?.toString() ??
          item['name']?.toString() ??
          item['description']?.toString() ??
          item['label']?.toString() ??
          item['itemName']?.toString() ??
          item['itemId']?.toString();
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              final canLeave = await _onWillPop();
              if (canLeave) Navigator.pop(context);
            },
          ),
          title: const SizedBox.shrink(),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 12, bottom: 0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      widget.selectedS,
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _getSDescription(widget.selectedS),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.only(top: 8, bottom: 4, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    QuestionnairePage.fixEncodingStatic(
                        currentCat['name'] ?? ''),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    QuestionnairePage.fixEncodingStatic(
                        currentCat['description'] ?? ''),
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: _QuestionView(
                  question:
                      QuestionnairePage.fixEncodingStatic(currentQ['question']),
                  itemName: itemName,
                  questionId: questionId,
                  itemId: itemId,
                  score: respuesta['score'],
                  comment: respuesta['comment'],
                  onChanged: (score, comment) =>
                      _onChanged(questionId, itemId, score, comment),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1487D4),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.13),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: currentQuestionIndex > 0
                          ? () {
                              setState(() {
                                currentQuestionIndex--;
                              });
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.arrow_back,
                                color: Colors.white, size: 24),
                            SizedBox(width: 6),
                            Text(
                              'Anterior',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: _isSaving ? null : _saveAnswers,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.13),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: _isSaving
                            ? const SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Color(0xFF1487D4),
                                ),
                              )
                            : const Icon(Icons.save,
                                size: 30, color: Color(0xFF1487D4)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: currentQuestionIndex < visualQuestions.length - 1
                          ? () {
                              setState(() {
                                currentQuestionIndex++;
                              });
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              'Siguiente',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward,
                                color: Colors.white, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getSDescription(String s) {
    switch (s) {
      case 'S1':
        return 'SEIRI';
      case 'S2':
        return 'SEITON';
      case 'S3':
        return 'SEISO';
      case 'S4':
        return 'SEIKETSU';
      case 'S5':
        return 'SHITSUKE';
      default:
        return '';
    }
  }
}

class _QuestionView extends StatefulWidget {
  final String? question;
  final String? itemName;
  final int questionId;
  final dynamic itemId;
  final int? score;
  final String? comment;
  final void Function(int? score, String? comment) onChanged;

  const _QuestionView({
    Key? key,
    this.question,
    this.itemName,
    required this.questionId,
    this.itemId,
    this.score,
    this.comment,
    required this.onChanged,
  }) : super(key: key);

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
              if (widget.itemName != null && widget.itemName!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  QuestionnairePage.fixEncodingStatic(widget.itemName!),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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
