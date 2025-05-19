import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app_5s/features/user_auth/presentation/pages/subareas_page.dart';

class AuditPage extends StatefulWidget {
  const AuditPage({Key? key}) : super(key: key);

  @override
  AuditPageState createState() => AuditPageState();
}

class AuditPageState extends State<AuditPage> {
  late Future<List<Map<String, dynamic>>> _areasFuture;
  List<Map<String, dynamic>> _areasList = [];
  List<Map<String, dynamic>> _filteredAreasList = [];

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
      _filteredAreasList = filteredAreas;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: Text('Error: \\${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No data found'),
            );
          }

          final responseList = _filteredAreasList;
          List<Widget> areasList = [];

          for (int i = 0; i < responseList.length; i++) {
            IconData icon;
            // Placeholder icons based on index
            if (i == 0) {
              icon = Icons.wc; // Toilet
            } else if (i == 1) {
              icon = Icons.local_bar; // Bottle
            } else {
              icon = Icons.cleaning_services; // Spray
            }
            areasList.add(
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubareasPage(
                        orgId: 2, // TODO: Replace with actual orgId if needed
                        areaId: int.parse(responseList[i]["id"]),
                        areaName: responseList[i]["area"],
                      ),
                    ),
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(214, 231, 239, 1),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 48, color: Colors.black87),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              responseList[i]["area"],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              responseList[i]["zona"],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.blue, size: 32),
                    ],
                  ),
                ),
              ),
            );
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_list),
                        label: const Text('Zona'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(230, 235, 245, 1),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.sort_by_alpha),
                        label: const Text('A-Z'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(230, 235, 245, 1),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ] +
                areasList,
          );
        },
      ),
    );
  }
}
