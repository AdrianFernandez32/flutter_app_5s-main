import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/area_info.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuditPage extends StatefulWidget {
  const AuditPage({Key? key}) : super(key: key);

  @override
  AuditPageState createState() => AuditPageState();
}

class AuditPageState extends State<AuditPage> {
  Future<List<Map<String, dynamic>>> fetchAreas() async {
    const orgId = 2; // Cambia esto si el orgId es dinámico
    final response = await http.get(
      Uri.parse('https://djnxv2fqbiqog.cloudfront.net/org/$orgId/area'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) {
        return {
          "id": item["id"].toString(),
          "area": item["name"] ?? "",
          "zona": item["description"] ?? ""
        };
      }).toList();
    } else {
      throw Exception("Error al cargar las áreas");
    }
  }

  @override
  Widget build(BuildContext context) {
    const appBarElementsColor = Color.fromRGBO(79, 67, 73, 1);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: colorScheme.secondary,
        title: const Text(
          "Auditar",
          style: TextStyle(color: Colors.white, fontSize: 32),
        ),
        leading: IconButton(
          onPressed: () {
            context.goNamed("Menu");
          },
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAreas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No se encontraron áreas"));
          }

          final areasList = snapshot.data!.map((area) {
            return AreaInfo(
              area: area["area"],
              zone: area["zona"],
              color: const Color.fromRGBO(214, 231, 239, 1),
              areaID: area["id"],
              textColor: Colors.black,
              goToNamed: 'Calificar 5s',
            );
          }).toList();

          return ListView(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                child: SearchBar(
                  onChanged: (value) {
                    // Puedes implementar lógica de búsqueda aquí
                    print(value);
                  },
                  leading: const SizedBox(width: 50, child: Icon(Icons.search)),
                  hintText: "Buscar",
                ),
              ),
              ...areasList,
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed('CreateQuestionnairePage');
        },
        backgroundColor: const Color.fromRGBO(240, 222, 229, 1),
        foregroundColor: appBarElementsColor,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
