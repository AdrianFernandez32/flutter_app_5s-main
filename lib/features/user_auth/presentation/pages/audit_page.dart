import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/area_info.dart';
import 'package:go_router/go_router.dart';

class AuditPage extends StatefulWidget {
  const AuditPage({Key? key}) : super(key: key);

  @override
  AuditPageState createState() => AuditPageState();
}

class AuditPageState extends State<AuditPage> {
  @override
  Widget build(BuildContext context) {
    const appBarElementsColor = Color.fromRGBO(79, 67, 73, 1);

    // Datos simulados de petición a base de datos
    List<Map<String, String>> responseList = [
      {"area": "Área de Embotellado", "zona": "Zona Operativa", "id": "1"},
      {"area": "Área de Higiene", "zona": "Zona Soporte", "id": "2"},
      {"area": "Área de Baños", "zona": "Zona de Comunes", "id": "3"},
    ];

    // Asignación dinámica de colores a los elementos de la lista de áreas
    List<Widget> areasList = [];

    int colorIndex = 1;

    // Colores default
    Color color = const Color.fromRGBO(255, 216, 235, 1);
    Color textColor = const Color.fromRGBO(55, 7, 41, 1);

    for (int i = 0; i < responseList.length; i++) {
      switch (colorIndex) {
        case 1:
          color = const Color.fromRGBO(255, 216, 235, 1);
          textColor = const Color.fromRGBO(55, 7, 41, 1);
          colorIndex++;
          break;
        case 2:
          color = const Color.fromRGBO(255, 220, 193, 1);
          textColor = const Color.fromRGBO(46, 21, 0, 1);
          colorIndex++;
          break;
        case 3:
          color = const Color.fromRGBO(174, 242, 197, 1);
          textColor = const Color.fromRGBO(0, 33, 16, 1);
          colorIndex = 1;
          break;
        default:
      }

      areasList.insert(
        i,
        AreaInfo(
          area: responseList[i]["area"],
          zone: responseList[i]["zona"],
          color: color,
          areaID: responseList[i]["id"],
          textColor: textColor,
          goToNamed: 'Calificar 5s',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromRGBO(240, 222, 229, 1),
        title: const Text(
          "Auditar",
          style: TextStyle(color: appBarElementsColor, fontSize: 32),
        ),
        leading: IconButton(
          onPressed: () {
            context.goNamed("Menu");
          },
          icon: const Icon(
            Icons.arrow_back,
            color: appBarElementsColor,
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
      body: ListView(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(20),
            child: SearchBar(
              onChanged: (value) {
                // Falta lógica de búsqueda
                // Pista: Modificar areasList y solo mostrar los que entren dentro de la búsqueda
                print(value);
              },
              leading: const SizedBox(width: 50, child: Icon(Icons.search)),
              hintText: "Buscar",
            ),
          ),
        ] + areasList,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed('CreateQuestionnairePage');
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromRGBO(240, 222, 229, 1),
        foregroundColor: appBarElementsColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
