import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/area_info.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AreasPage extends StatefulWidget {
  const AreasPage({Key? key}) : super(key: key);

  @override
  AreasPageState createState() => AreasPageState();
}

class AreasPageState extends State<AreasPage> {
  late Future<List<Map<String, dynamic>>> _areasFuture;
  List<Map<String, dynamic>> _areasList = [];
  List<Map<String, dynamic>> _filteredAreasList = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _areasFuture = _fetchAreas();
  }

  Future<List<Map<String, dynamic>>> _fetchAreas() async {
    final response = await Supabase.instance.client
        .from('subarea')
        .select('id, name, area:area_id(name)');

    final data = response as List<dynamic>;
    final areas = data.map((item) {
      final area = item['area'] as Map<String, dynamic>;
      return {
        "id": item['id'].toString(),
        "area": item['name'],
        "zona": area['name'],
      };
    }).toList();

    setState(() {
      _areasList = areas;
      _filteredAreasList = areas;
    });

    return areas;
  }

  void _filterAreas(String query) {
    final filteredAreas = _areasList.where((area) {
      final areaName = area["area"]!.toLowerCase();
      final zoneName = area["zona"]!.toLowerCase();
      final searchQuery = query.toLowerCase();

      return areaName.contains(searchQuery) || zoneName.contains(searchQuery);
    }).toList();

    setState(() {
      _searchQuery = query;
      _filteredAreasList = filteredAreas;
    });
  }

  @override
  Widget build(BuildContext context) {
    const appBarElementsColor = Color.fromRGBO(79, 67, 73, 1);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromRGBO(240, 222, 229, 1),
        title: const Text(
          "Áreas",
          style: TextStyle(
            color: appBarElementsColor,
            fontSize: 32,
          ),
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
          preferredSize: const Size.fromHeight(
            10,
          ),
          child: Container(
            color: const Color.fromRGBO(134, 75, 111, 1),
            height: 2,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _areasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No data found'),
            );
          }

          final responseList = _filteredAreasList;
          List<Widget> areasList = [];

          for (int i = 0; i < responseList.length; i++) {
            Color color;
            Color textColor;

            switch (responseList[i]["zona"]) {
              case "Zona Soporte":
                color = const Color.fromRGBO(255, 216, 235, 1);
                textColor = const Color.fromRGBO(55, 7, 41, 1);
                break;
              case "Zona Operativa":
                color = const Color.fromRGBO(255, 220, 193, 1);
                textColor = const Color.fromRGBO(46, 21, 0, 1);
                break;
              case "Zona de Comunes":
                color = const Color.fromRGBO(174, 242, 197, 1);
                textColor = const Color.fromRGBO(0, 33, 16, 1);
                break;
              default:
                color = Colors.grey; // Default color if no match found
                textColor = Colors.black;
            }

            areasList.add(AreaInfo(
              area: responseList[i]["area"],
              zone: responseList[i]["zona"],
              color: color,
              areaID: responseList[i]["id"],
              textColor: textColor,
            ));
          }
          return ListView(
            children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: TextField(
                      onChanged: (value) {
                        _filterAreas(value);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromRGBO(240, 222, 229, 1),
                        prefixIcon: const Icon(Icons.search,
                            color: Color.fromRGBO(134, 75, 111, 1)),
                        hintText: "Buscar",
                        hintStyle: const TextStyle(
                          color: Color.fromRGBO(55, 7, 41, 1),
                          fontWeight: FontWeight.bold,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 20),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ] +
                areasList,
          );
        },
      ),
      floatingActionButton: const _SpeedDial(),
    );
  }
}

class _SpeedDial extends StatefulWidget {
  const _SpeedDial({Key? key}) : super(key: key);

  @override
  _SpeedDialState createState() => _SpeedDialState();
}

class _SpeedDialState extends State<_SpeedDial> {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      backgroundColor: const Color.fromRGBO(243, 228, 233, 1),
      foregroundColor: const Color.fromRGBO(134, 75, 111, 1),
      spaceBetweenChildren: 12,
      animatedIcon: AnimatedIcons.menu_close,
      label: const Text("Editar"),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      children: [
        SpeedDialChild(
          label: "Editar Área",
          labelBackgroundColor: const Color.fromRGBO(243, 228, 233, 1),
          labelStyle: const TextStyle(
              color: Color.fromRGBO(134, 75, 111, 1),
              fontWeight: FontWeight.w600),
          backgroundColor: const Color.fromRGBO(243, 228, 233, 1),
          foregroundColor: const Color.fromRGBO(134, 75, 111, 1),
          child: const Icon(Icons.edit_rounded),
          onTap: () {
            context.goNamed("Editar Areas");
          },
        ),
        SpeedDialChild(
          label: "Crear Área",
          labelBackgroundColor: const Color.fromRGBO(243, 228, 233, 1),
          labelStyle: const TextStyle(
              color: Color.fromRGBO(134, 75, 111, 1),
              fontWeight: FontWeight.w600),
          backgroundColor: const Color.fromRGBO(243, 228, 233, 1),
          foregroundColor: const Color.fromRGBO(134, 75, 111, 1),
          child: const Icon(Icons.add),
          onTap: () {
            print("Crear");
          },
        )
      ],
    );
  }
}
