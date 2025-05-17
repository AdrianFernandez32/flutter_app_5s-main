import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class CreateQuestionnairePage extends StatefulWidget {
  const CreateQuestionnairePage({Key? key}) : super(key: key);

  @override
  _CreateQuestionnairePageState createState() =>
      _CreateQuestionnairePageState();
}

class _CreateQuestionnairePageState extends State<CreateQuestionnairePage>
    with TickerProviderStateMixin {
  late TextEditingController _preguntaController;
  late TextEditingController _tituloController;
  late TabController _tabController;

  bool _isValid = false;
  String _selectedS = '1';
  String? _selectedSubArea;
  List<Map<String, dynamic>> _subAreas = [];
  final List<String> _preguntas = ['Pregunta 1'];
  final List<TextEditingController> _preguntaControllers = [
    TextEditingController()
  ];

  @override
  void initState() {
    super.initState();
    _preguntaController = TextEditingController();
    _tituloController = TextEditingController();
    _preguntaController.addListener(_validateInputs);
    _fetchSubAreas();
    _tabController = TabController(length: _preguntas.length, vsync: this);
  }

  @override
  void dispose() {
    _preguntaController.dispose();
    _tituloController.dispose();
    _tabController.dispose();
    for (var controller in _preguntaControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      _isValid = _preguntaController.text.isNotEmpty;
    });
  }

  Future<void> _fetchSubAreas() async {
    final response =
        await Supabase.instance.client.from('subarea').select('id, name');

    final data = response as List<dynamic>;
    final areas = data.map((item) {
      return {
        "id": item['id'].toString(),
        "name": item['name'],
      };
    }).toList();

    setState(() {
      _subAreas = areas;
      _selectedSubArea = _subAreas.isNotEmpty
          ? _subAreas[0]['name']
          : null; // Use name instead of id
    });
  }

  Future<void> _storeDataAndSubmit() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('No user authenticated');
      return;
    }

    final title = _tituloController.text;
    final sSelected = _selectedS;
    final subAreaName = _selectedSubArea; // Use the name of the sub-area
    final dateNow = DateTime.now().toIso8601String();
    final userName = user.userMetadata?['name'] ?? 'Unknown';

    // Insertar el cuestionario
    final response =
        await Supabase.instance.client.from('questionnaire').insert({
      'name': title,
      's_id': sSelected,
      'sub_area': subAreaName, // Store the name of the sub-area
      'active': true,
      'created_at': dateNow,
      'created_by': userName,
      'updated_at': dateNow,
      'updated_by': userName,
    });

    // Obtener el ID del cuestionario recién insertado
    final fresponse = await Supabase.instance.client
        .from('questionnaire')
        .select('id')
        .order('id', ascending: false)
        .limit(1)
        .single();

    final newQuestionnaireId = fresponse['id'];

    // Insertar las preguntas utilizando el ID del cuestionario
    for (var controller in _preguntaControllers) {
      await Supabase.instance.client.from('question').insert({
        'name': controller.text,
        'questionnaire_id': newQuestionnaireId,
        'created_at': dateNow,
        'created_by': userName,
        'updated_at': dateNow,
        'updated_by': userName,
      });
    }
  }

  void _addPregunta() {
    setState(() {
      _preguntas.add('Pregunta ${_preguntas.length + 1}');
      _preguntaControllers.add(TextEditingController());

      _tabController.dispose();
      _tabController = TabController(length: _preguntas.length, vsync: this);
      _tabController
          .animateTo(_preguntas.length - 1); // Cambiar al nuevo índice
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(240, 222, 229, 1),
        leading: IconButton(
          onPressed: () {
            context.goNamed(
                'Auditar'); // Asegúrate de que esta ruta existe en tu configuración de GoRouter
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromRGBO(79, 67, 73, 1),
            size: 33,
          ),
        ),
        title: const Text('Crear Cuestionario'),
      ),
      body: Container(
        color: const Color(0xfffff8f8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Selecciona la S del cuestionario',
                  border: OutlineInputBorder(),
                ),
                value: _selectedS,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('1S')),
                  DropdownMenuItem(value: '2', child: Text('2S')),
                  DropdownMenuItem(value: '3', child: Text('3S')),
                  DropdownMenuItem(value: '4', child: Text('4S')),
                  DropdownMenuItem(value: '5', child: Text('5S')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedS = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Área',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSubArea,
                items: _subAreas.map<DropdownMenuItem<String>>((subArea) {
                  return DropdownMenuItem<String>(
                    value: subArea['name'], // Use name instead of id
                    child: Text(subArea['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubArea = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: DefaultTabController(
                length: _preguntas.length,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      indicatorColor: const Color(0xff864b6f),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      isScrollable: true,
                      tabs: _preguntas
                          .map((preg) => Tab(child: Text(preg)))
                          .toList(),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: _preguntaControllers.map((controller) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Escribe tu pregunta aquí',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _addPregunta,
                child: const Text('Añadir Pregunta'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isValid ? _storeDataAndSubmit : null,
                child: const Text('Guardar Cuestionario'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
