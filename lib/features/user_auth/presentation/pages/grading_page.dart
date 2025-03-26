import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GradingPage extends StatelessWidget {
  const GradingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Porcentaje simulado
    const double progress = .329411;

    // Transformar decimal a formato de porcentaje
    String progressString = "${(progress * 100).toStringAsFixed(0)}%";

    // Cuestionarios tomados de una base de datos simulada
    List<List<Map<String, String>>> responseQuestionaries = [
      [
        {
          "title": "Materiales Innecesarios",
          "id": "1",
          "num_preguntas": "5",
          "preguntas_contestadas": "5",
        },
        {
          "title": "Herramientas Innecesarias",
          "id": "2",
          "num_preguntas": "5",
          "preguntas_contestadas": "3",
        },
        {
          "title": "Máquinas o Equipos Innecesarios",
          "id": "3",
          "num_preguntas": "5",
          "preguntas_contestadas": "3",
        },
        {
          "title": "Documentos Innecesarios",
          "id": "4",
          "num_preguntas": "5",
          "preguntas_contestadas": "1",
        },
        {
          "title": "Etiquetaje",
          "id": "5",
          "num_preguntas": "5",
          "preguntas_contestadas": "0",
        },
      ],
      [
        {
          "title": "Cuestionario 6",
          "id": "6",
          "num_preguntas": "5",
          "preguntas_contestadas": "4",
        },
        {
          "title": "Cuestionario 7",
          "id": "7",
          "num_preguntas": "5",
          "preguntas_contestadas": "4",
        },
        {
          "title": "Cuestionario 8",
          "id": "8",
          "num_preguntas": "5",
          "preguntas_contestadas": "5",
        },
      ],
      [
        {
          "title": "Cuestionario 9",
          "id": "9",
          "num_preguntas": "5",
          "preguntas_contestadas": "2",
        },
        {
          "title": "Cuestionario 10",
          "id": "10",
          "num_preguntas": "5",
          "preguntas_contestadas": "1",
        },
        {
          "title": "Cuestionario 11",
          "id": "11",
          "num_preguntas": "5",
          "preguntas_contestadas": "0",
        },
      ],
      [
        {
          "title": "Cuestionario 12",
          "id": "12",
          "num_preguntas": "5",
          "preguntas_contestadas": "0",
        },
        {
          "title": "Cuestionario 13",
          "id": "13",
          "num_preguntas": "5",
          "preguntas_contestadas": "0",
        },
        {
          "title": "Cuestionario 14",
          "id": "14",
          "num_preguntas": "5",
          "preguntas_contestadas": "0",
        },
      ],
      [
        {
          "title": "Cuestionario 15",
          "id": "15",
          "num_preguntas": "5",
          "preguntas_contestadas": "0",
        },
        {
          "title": "Cuestionario 16",
          "id": "16",
          "num_preguntas": "5",
          "preguntas_contestadas": "0",
        },
        {
          "title": "Cuestionario 17",
          "id": "17",
          "num_preguntas": "5",
          "preguntas_contestadas": "0",
        },
      ],
    ];

    // Asignar la lista de cuestionarios a cada S solo si existe, sino dejar una lista vacía.
    int len = responseQuestionaries.length;
    List<Map<String, String>> s1 = [], s2 = [], s3 = [], s4 = [], s5 = [];
    if (0 < len) {
      s1 = responseQuestionaries[0];
    }
    if (1 < len) {
      s2 = responseQuestionaries[1];
    }
    if (2 < len) {
      s3 = responseQuestionaries[2];
    }
    if (3 < len) {
      s4 = responseQuestionaries[3];
    }
    if (4 < len) {
      s5 = responseQuestionaries[4];
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              context.goNamed("Auditar");
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color.fromRGBO(79, 67, 73, 1),
              size: 33,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                      margin: const EdgeInsets.only(top: 30, bottom: 30),
                      height: 120,
                      child: Column(
                        children: [
                          const Expanded(
                            child: SizedBox(),
                          ),
                          Text(
                            progressString,
                            style: const TextStyle(
                                fontSize: 46, fontWeight: FontWeight.w600),
                          ),
                          const Expanded(
                            child: SizedBox(),
                          ),
                        ],
                      )),
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 30),
                    height: 130,
                    width: 130,
                    child: const CircularProgressIndicator(
                      strokeCap: StrokeCap.round,
                      strokeWidth: 8,
                      value: progress,
                      color: Color.fromRGBO(107, 52, 87, 1),
                      backgroundColor: Color.fromRGBO(211, 194, 201, 1),
                    ),
                  ),
                ),
              ],
            ),
            _QuestionsInfo(
                title: '1S',
                description: '1S SEIRI',
                progress: .3,
                questionaries: s1),
            _QuestionsInfo(
                title: '2S',
                description: '2S SEITON',
                progress: .6,
                questionaries: s2),
            _QuestionsInfo(
                title: '3S',
                description: '3S SEISON',
                progress: .8,
                questionaries: s3),
            _QuestionsInfo(
                title: '4S',
                description: '4S SEIKESTSU',
                progress: .15,
                questionaries: s4),
            _QuestionsInfo(
                title: '5S',
                description: '5S SHITSUKE',
                progress: .3,
                questionaries: s5),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

// Widget dedicado a mostrar los cuestionarios por sección
class _QuestionsInfo extends StatefulWidget {
  final String title;
  final String description;
  final double progress;
  final List<Map<String, String>> questionaries;

  const _QuestionsInfo(
      {Key? key,
      required this.title,
      required this.description,
      required this.progress,
      required this.questionaries})
      : super(key: key);

  @override
  _QuestionsInfoState createState() => _QuestionsInfoState();
}

class _QuestionsInfoState extends State<_QuestionsInfo> {
  // Variable que maneja el estado
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    // Asignar color dependiendo de el porcentaje completado de la sección
    Color colorProgressBar = const Color.fromARGB(255, 109, 0, 136);
    if (widget.progress < 0.34) {
      colorProgressBar = const Color.fromRGBO(222, 55, 48, 1);
    } else if (widget.progress < 0.66) {
      colorProgressBar = const Color.fromRGBO(204, 126, 49, 1);
    } else if (widget.progress > 0.65) {
      colorProgressBar = const Color.fromRGBO(96, 158, 120, 1);
    }

    List<Widget> columnNoSelectedData = [
      Container(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          widget.description,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(134, 75, 111, 1)),
        ),
      ),
      const SizedBox(
        height: 26,
      ),
      LinearProgressIndicator(
        value: widget.progress,
        backgroundColor: Colors.white,
        color: colorProgressBar,
        borderRadius: BorderRadius.circular(20),
      ),
      const SizedBox(
        height: 12,
      ),
    ];

    List<Widget> columnSelectedData = [
      SizedBox(
        height: 120,
        child: Column(
          children: [
            const Expanded(child: SizedBox()),
            Text(
              widget.title,
              style: const TextStyle(
                  color: Color.fromRGBO(134, 75, 111, 1),
                  fontSize: 46,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              widget.description,
              style: const TextStyle(
                  color: Color.fromRGBO(134, 75, 111, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
      for (int i = 0; i < widget.questionaries.length; i++)
        GestureDetector(
          onTap: () {
            // Actualizar ruta cuando esté 
            context.goNamed("Cuestionario");
          },
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            height: 70,
            width: double.infinity,
            child: Column(
              children: [
                const Divider(),
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 26,
                        child: Text(
                          "${i + 1}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.questionaries[i]["title"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: null,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 26,
                      ),
                      Text(
                        "${widget.questionaries[i]["preguntas_contestadas"]}/${widget.questionaries[i]["num_preguntas"]} preguntas",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      const SizedBox(
        height: 20,
      ),
    ];

    return GestureDetector(
      onTap: () {
        if (!selected) {
          setState(() {
            selected = !selected;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(left: !selected ? 15 : 0),
              padding: EdgeInsets.only(left: !selected ? 72 : 0),
              decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 216, 235, 1),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Row(
                children: [
                  Expanded(
                      child: AnimatedSize(
                    duration: Durations.short4,
                    child: Column(
                      crossAxisAlignment: !selected
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children:
                          !selected ? columnNoSelectedData : columnSelectedData,
                    ),
                  )),
                  if (!selected)
                    const SizedBox(
                      width: 50,
                    ),
                ],
              ),
            ),
            if (!selected)
              Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color.fromRGBO(134, 75, 111, 1),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        widget.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 46,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            AnimatedAlign(
              alignment: Alignment.centerRight,
              heightFactor: !selected ? 1.2 : .8,
              duration: Durations.short3,
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      selected = !selected;
                    });
                  },
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(
                    !selected
                        ? Icons.keyboard_arrow_right_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 48,
                    color: const Color.fromRGBO(134, 75, 111, 1),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
