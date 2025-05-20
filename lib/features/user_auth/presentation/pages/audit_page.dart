import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app_5s/features/user_auth/presentation/pages/subareas_page.dart';
import 'package:flutter_app_5s/auth/auth_service.dart';

class AuditPage extends StatefulWidget {
  const AuditPage({Key? key}) : super(key: key);

  @override
  AuditPageState createState() => AuditPageState();
}

class AuditPageState extends State<AuditPage> {
  late Future<List<Map<String, dynamic>>> _areasFuture;
  List<Map<String, dynamic>> _areasList = [];
  List<Map<String, dynamic>> _filteredAreasList = [];
  int? _orgId;

  @override
  void initState() {
    super.initState();
    _areasFuture = _fetchAreas();
  }

  Future<int> _fetchOrgId() async {
    final authService = AuthService();
    final accessToken = authService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('No has iniciado sesión.');
    }
    final response = await http.get(
      Uri.parse('https://djnxv2fqbiqog.cloudfront.net/org/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> orgs = json.decode(response.body);
      if (orgs.isEmpty) {
        throw Exception('No perteneces a ninguna organización.');
      }
      return orgs[0]['id'];
    } else {
      throw Exception(
          'Error al obtener la organización: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAreas() async {
    try {
      final orgId = await _fetchOrgId();
      setState(() {
        _orgId = orgId;
      });
      final authService = AuthService();
      final accessToken = authService.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No has iniciado sesión.');
      }
      final response = await http.get(
        Uri.parse('https://djnxv2fqbiqog.cloudfront.net/org/$orgId/area'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
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
        throw Exception('Error al cargar áreas: \\${response.statusCode}');
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

  Future<void> _showCreateAreaDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear nueva área'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              try {
                final authService = AuthService();
                final accessToken = authService.accessToken;
                if (_orgId == null) throw Exception('No orgId');
                final response = await http.post(
                  Uri.parse(
                      'https://djnxv2fqbiqog.cloudfront.net/org/${_orgId}/area'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $accessToken',
                  },
                  body: jsonEncode({
                    'name': nameController.text,
                    'description': descController.text,
                    'logoUrl': 'https://via.placeholder.com/150',
                  }),
                );
                if (response.statusCode == 201 || response.statusCode == 200) {
                  Navigator.of(context).pop();
                  setState(() {
                    _areasFuture = _fetchAreas();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Error al crear área: \\${response.statusCode}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
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
            if (i == 0) {
              icon = Icons.wc;
            } else if (i == 1) {
              icon = Icons.local_bar;
            } else {
              icon = Icons.cleaning_services;
            }
            areasList.add(
              GestureDetector(
                onTap: () {
                  if (_orgId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'No se encontró la organización del usuario.')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubareasPage(
                        orgId: _orgId!,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAreaDialog,
        child: const Icon(Icons.add),
        tooltip: 'Crear área',
      ),
    );
  }
}
