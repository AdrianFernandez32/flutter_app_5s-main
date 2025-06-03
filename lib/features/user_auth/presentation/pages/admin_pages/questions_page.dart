import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_question_tile.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_appbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_navbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/floating_plus_action_button.dart';
import 'package:flutter_app_5s/utils/global_states/admin_id_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_app_5s/auth/auth_service.dart';
import 'package:go_router/go_router.dart';

class AdminQuestionsPage extends StatefulWidget {
  @override
  State<AdminQuestionsPage> createState() => _AdminQuestionsPageState();
}

class _AdminQuestionsPageState extends State<AdminQuestionsPage> {
  final AuthService authService = AuthService();
  List<dynamic> questions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final baseCategoryId =
        Provider.of<AdminIdProvider>(context, listen: false).baseCategoryId;
    if (baseCategoryId == null) {
      setState(() {
        errorMessage = 'No se ha seleccionado una categoría';
        isLoading = false;
      });
      return;
    }

    try {
      final result = await fetchQuestions(baseCategoryId);
      setState(() {
        questions = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _showCreateQuestionDialog() {
    final TextEditingController questionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Nueva Pregunta'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Pregunta',
                hintText: 'Ingrese la pregunta',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una pregunta';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final question = questionController.text.trim();
                  Navigator.of(dialogContext).pop();
                  await _createQuestion(question);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createQuestion(String question) async {
    final baseCategoryId =
        Provider.of<AdminIdProvider>(context, listen: false).baseCategoryId;
    if (baseCategoryId == null) return;

    try {
      final accessToken = authService.accessToken;
      if (accessToken == null) {
        throw Exception('No hay token de acceso disponible');
      }

      final baseUrl = dotenv.env['API_URL'];
      if (baseUrl == null) {
        throw Exception('Error de configuración: API_URL no definida');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/base/questions/$baseCategoryId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'question': question}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pregunta creada exitosamente')),
          );
          await _loadQuestions(); // Recargar preguntas
        }
      } else {
        throw Exception('Error al crear pregunta: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showEditQuestionDialog(int questionId, String currentQuestion) {
    final TextEditingController questionController =
        TextEditingController(text: currentQuestion);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Editar Pregunta'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Pregunta',
                hintText: 'Ingrese la pregunta',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una pregunta';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final question = questionController.text.trim();
                  Navigator.of(dialogContext).pop();
                  await _updateQuestion(questionId, question);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteQuestionDialog(int questionId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar Pregunta'),
          content: const Text(
              '¿Está seguro de que desea eliminar esta pregunta? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteQuestion(questionId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateBaseItemDialog(int questionId) {
    final TextEditingController itemController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Nueva Respuesta'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: itemController,
              decoration: const InputDecoration(
                labelText: 'Respuesta',
                hintText: 'Ingrese la respuesta',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una respuesta';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final item = itemController.text.trim();
                  Navigator.of(dialogContext).pop();
                  await _createBaseItem(questionId, item);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showEditBaseItemDialog(int baseItemId, String currentItem) {
    final TextEditingController itemController =
        TextEditingController(text: currentItem);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Editar Respuesta'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: itemController,
              decoration: const InputDecoration(
                labelText: 'Respuesta',
                hintText: 'Ingrese la respuesta',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una respuesta';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final item = itemController.text.trim();
                  Navigator.of(dialogContext).pop();
                  await _updateBaseItem(baseItemId, item);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteBaseItemDialog(int baseItemId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar Respuesta'),
          content:
              const Text('¿Está seguro de que desea eliminar esta respuesta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteBaseItem(baseItemId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateQuestion(int questionId, String question) async {
    try {
      final accessToken = authService.accessToken;
      if (accessToken == null) {
        throw Exception('No hay token de acceso disponible');
      }

      final baseUrl = dotenv.env['API_URL'];
      if (baseUrl == null) {
        throw Exception('Error de configuración: API_URL no definida');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/base/questions/$questionId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'question': question}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pregunta actualizada exitosamente')),
          );
          await _loadQuestions();
        }
      } else {
        throw Exception('Error al actualizar pregunta: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteQuestion(int questionId) async {
    try {
      final accessToken = authService.accessToken;
      if (accessToken == null) {
        throw Exception('No hay token de acceso disponible');
      }

      final baseUrl = dotenv.env['API_URL'];
      if (baseUrl == null) {
        throw Exception('Error de configuración: API_URL no definida');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/base/questions/$questionId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pregunta eliminada exitosamente')),
          );
          await _loadQuestions();
        }
      } else {
        throw Exception('Error al eliminar pregunta: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _createBaseItem(int questionId, String item) async {
    try {
      final accessToken = authService.accessToken;
      if (accessToken == null) {
        throw Exception('No hay token de acceso disponible');
      }

      final baseUrl = dotenv.env['API_URL'];
      if (baseUrl == null) {
        throw Exception('Error de configuración: API_URL no definida');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/base/items/$questionId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'item': item}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Respuesta creada exitosamente')),
          );
          await _loadQuestions();
        }
      } else {
        throw Exception('Error al crear respuesta: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _updateBaseItem(int baseItemId, String item) async {
    try {
      final accessToken = authService.accessToken;
      if (accessToken == null) {
        throw Exception('No hay token de acceso disponible');
      }

      final baseUrl = dotenv.env['API_URL'];
      if (baseUrl == null) {
        throw Exception('Error de configuración: API_URL no definida');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/base/items/$baseItemId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'item': item}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Respuesta actualizada exitosamente')),
          );
          await _loadQuestions();
        }
      } else {
        throw Exception(
            'Error al actualizar respuesta: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteBaseItem(int baseItemId) async {
    try {
      final accessToken = authService.accessToken;
      if (accessToken == null) {
        throw Exception('No hay token de acceso disponible');
      }

      final baseUrl = dotenv.env['API_URL'];
      if (baseUrl == null) {
        throw Exception('Error de configuración: API_URL no definida');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/base/items/$baseItemId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Respuesta eliminada exitosamente')),
          );
          await _loadQuestions();
        }
      } else {
        throw Exception('Error al eliminar respuesta: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(
        title: 'Preguntas',
        onBackPressed: () {
          context.goNamed('FiveSMenu');
        },
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text('Error: $errorMessage'))
                    : questions.isEmpty
                        ? const Center(
                            child: Text('No hay preguntas disponibles'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: questions.length,
                            itemBuilder: (context, index) {
                              final question = questions[index];
                              return QuestionTile(
                                question:
                                    question['question'] ?? 'Sin pregunta',
                                questionId: question['id'] ?? 0,
                                baseItems: question['baseItems'] ?? [],
                                onEditQuestion: () => _showEditQuestionDialog(
                                  question['id'] ?? 0,
                                  question['question'] ?? '',
                                ),
                                onDeleteQuestion: () =>
                                    _showDeleteQuestionDialog(
                                  question['id'] ?? 0,
                                ),
                                onAddBaseItem: () => _showCreateBaseItemDialog(
                                  question['id'] ?? 0,
                                ),
                                onEditBaseItem: (baseItemId, currentItem) =>
                                    _showEditBaseItemDialog(
                                        baseItemId, currentItem),
                                onDeleteBaseItem: (baseItemId) =>
                                    _showDeleteBaseItemDialog(baseItemId),
                              );
                            },
                          ),
          ),
          const AdminNavBar(),
          FloatingPlusActionButton(
            onPressed: _showCreateQuestionDialog,
          ),
        ],
      ),
    );
  }

  Future<List> fetchQuestions(String baseCategoryId) async {
    try {
      final accessToken = authService.accessToken;
      if (accessToken == null) {
        throw Exception('No hay token de acceso disponible');
      }

      final baseUrl = dotenv.env['API_URL'];
      if (baseUrl == null) {
        throw Exception('Error de configuración: API_URL no definida');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/base/questions/$baseCategoryId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error al cargar preguntas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
