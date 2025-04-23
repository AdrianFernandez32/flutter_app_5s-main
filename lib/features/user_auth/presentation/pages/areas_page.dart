import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/area_info.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    try {
      final orgId = 2; // Cambia este ID según el que necesites
      final response = await http.get(
        Uri.parse('https://djnxv2fqbiqog.cloudfront.net/org/$orgId/area'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final areas = data.map((area) {
          return {
            "id": area["id"].toString(),
            "area": area["name"] ?? "",
            "zona": area["description"] ?? "",
          };
        }).toList();

        setState(() {
          _areasList = List<Map<String, dynamic>>.from(areas);
          _filteredAreasList = _areasList;
        });

        return _areasList;
      } else {
        throw Exception('Error al cargar áreas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: colorScheme.secondary,
        title: const Text(
          "Áreas",
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
            Color color = Color.fromRGBO(214, 231, 239, 1);
            Color textColor = Colors.black;

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

    );
  }
}





