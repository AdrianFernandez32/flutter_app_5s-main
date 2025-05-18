import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class ManageQuestionnariesPage extends StatelessWidget {
  const ManageQuestionnariesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appBarElementsColor = Color.fromRGBO(79, 67, 73, 1);

    List<Map<String, String>> response = [
      {
        "id": "1",
        "title": "Cuestionario 1",
        "zone": "Zona xxxx",
      },
      {
        "id": "2",
        "title": "Cuestionario 2",
        "zone": "Zona xxxx",
      },
      {
        "id": "3",
        "title": "Cuestionario 3",
        "zone": "Zona xxxx",
      },
    ];

    List<Widget> columnElements = [];
    for (var i = 0; i < response.length; i++) {
      columnElements.add(_QuestionnaireWidget(
        title: response[i]["title"] ?? "",
        zone: response[i]["zone"] ?? "",
        id: response[i]["id"] ?? "",
      ));
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromRGBO(240, 222, 229, 1),
        title: const Text(
          "Cuestionarios",
          style: TextStyle(color: appBarElementsColor, fontSize: 28),
        ),
        leading: IconButton(
            onPressed: () {
              context.goNamed("Menu");
            },
            icon: const Icon(
              Icons.arrow_back,
              color: appBarElementsColor,
              size: 33,
            )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Container(
            color: const Color.fromRGBO(134, 75, 111, 1),
            height: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(20),
                  child: SearchBar(
                    onChanged: (value) {
                      // Falta lógica de búsqueda
                      // Pista: Modificar areasList y solo mostrar los que entren dentro de la búsqueda
                      print(value);
                    },
                    leading:
                        const SizedBox(width: 50, child: Icon(Icons.search)),
                    hintText: "Buscar",
                  ),
                ),
              ] +
              columnElements,
        ),
      ),
    );
  }
}

class _QuestionnaireWidget extends StatelessWidget {
  final String title;
  final String zone;
  final String id;

  const _QuestionnaireWidget(
      {Key? key, required this.title, required this.zone, required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = this.title;
    String zone = this.zone;
    // String id = this.id;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Stack(
        children: [
          Container(
            height: 80,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                border: Border.symmetric(
                    horizontal: BorderSide(
                        color: Color.fromRGBO(240, 222, 229, 1), width: 2),
                    vertical: BorderSide(
                        color: Color.fromRGBO(240, 222, 229, 1), width: 2))),
            child: Row(
              children: [
                const SizedBox(
                  width: 85,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: SizedBox(),
                      ),
                      Text(title),
                      Text(zone),
                      const Expanded(
                        child: SizedBox(),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Color.fromRGBO(134, 75, 111, 1),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 80,
              width: 80,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      "lib/assets/images/vino.jpg",
                    ),
                  ),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16))),
            ),
          ),
        ],
      ),
    );
  }
}
