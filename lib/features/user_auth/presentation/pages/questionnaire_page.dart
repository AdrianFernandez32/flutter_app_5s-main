import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({Key? key}) : super(key: key);

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  @override
  Widget build(BuildContext context) {
    const List<Map<String, String>> response = [
      {
        "id": "1",
        "pregunta": "¿Cuál es la raíz cuadrada de 16?",
      },
      {
        "id": "2",
        "pregunta":
            "¿Aquí va una pregunta muy larga para probar el textOverflow de pixeles?",
      },
      {
        "id": "3",
        "pregunta": "¿Esta es otra pregunta?",
      },
      {
        "id": "4",
        "pregunta": "¿Cuál es el sentido de la vida?",
      }
    ];

    int length = response.length;

    List<Widget> tabs = [];
    List<Widget> tabsViews = [];

    for (var i = 0; i < length; i++) {
      tabs.insert(
          i,
          Tab(
            text: "Pregunta ${i + 1}",
          ));
      tabsViews.insert(
          i,
          _QuestionView(
            question: response[i]["pregunta"],
          ));
    }

    return DefaultTabController(
      length: length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 180,
          title: const Center(
            child: Text(
              "S1 SEIRI",
              style: TextStyle(
                  color: Color.fromRGBO(46, 21, 0, 1),
                  fontSize: 50,
                  fontWeight: FontWeight.bold),
            ),
          ),
          bottom: TabBar(
            tabs: tabs,
            isScrollable: true,
          ),
        ),
        body: TabBarView(
          children: tabsViews,
        ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final String? question;

  const _QuestionView({Key? key, this.question}) : super(key: key);

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
                question ?? "No hay pregunta",
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 30,
              ),
              const _OptionsRadios(),
              const SizedBox(
                height: 30,
              ),
              _CommentField(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionsRadios extends StatefulWidget {
  const _OptionsRadios({Key? key}) : super(key: key);

  @override
  _OptionsRadiosState createState() => _OptionsRadiosState();
}

List<String> options = ["0", "1", "2", "3", "4", "5"];

class _OptionsRadiosState extends State<_OptionsRadios> {
  String currentOption = options[0];

  @override
  Widget build(BuildContext context) {
    List<Widget> radios = [];
    for (var i = 0; i < options.length; i++) {
      radios.insert(
        i,
        Column(
          children: [
            Radio(
              value: options[i],
              groupValue: currentOption,
              onChanged: ((value) {
                setState(() {
                  currentOption = value.toString();
                });
              }),
            ),
            Text(
              options[i],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }
    radios.insert(
        radios.length,
        const Expanded(
          child: SizedBox(),
        ));
    radios.insert(
        0,
        const Expanded(
          child: SizedBox(),
        ));

    return Row(children: radios);
  }
}

class _CommentField extends StatefulWidget {
  @override
  __CommentFieldState createState() => __CommentFieldState();
}

class __CommentFieldState extends State<_CommentField> {
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
          Row(children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.add_photo_alternate_rounded)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.sticky_note_2_outlined)),
          ],)
        ],
      ),
    );
  }
}
