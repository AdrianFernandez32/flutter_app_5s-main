import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ZonesPage extends StatefulWidget {
  const ZonesPage({super.key});

  @override
  State<ZonesPage> createState() => _ZonesPageState();
}

class _ZonesPageState extends State<ZonesPage> {
  late Future<List<Map<String, dynamic>>> _areasFuture;

  @override
  void initState() {
    super.initState();
    _areasFuture = _fetchAreas();
  }

  Future<List<Map<String, dynamic>>> _fetchAreas() async {
    final orgId = 2; // Cambia si es dinámico
    final response = await http.get(
      Uri.parse('https://djnxv2fqbiqog.cloudfront.net/org/$orgId/area'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) {
        return {
          "id": item["id"].toString(),
          "area": item["name"] ?? "",
          "zona": item["description"] ?? "",
        };
      }).toList();
    } else {
      throw Exception('Error al obtener las áreas');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: colorScheme.secondary,
        title: const Text(
          "Auditorías",
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron áreas'));
          }

          final responseList = snapshot.data!;
          List<Widget> areasList = responseList.map((item) {
            Color color = const Color.fromRGBO(214, 231, 239, 1);
            Color textColor = Colors.black;

            return AuditWidget(
              area: item["area"],
              zone: item["zona"],
              color: color,
              areaID: item["id"],
              textColor: textColor,
            );
          }).toList();

          return ListView(children: areasList);
        },
      ),
    );
  }
}

class AuditWidget extends StatelessWidget {
  final String? area;
  final String? zone;
  final Color color;
  final Color textColor;
  final String? areaID;

  const AuditWidget({
    Key? key,
    required this.area,
    required this.zone,
    required this.color,
    required this.areaID,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: GestureDetector(
        onTap: () {
          context.goNamed(
            'Audits Page',
            pathParameters: {
              'zone': zone ?? "",
              'area': area ?? "",
            },
            extra: color,
          );
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: color,
              ),
              height: 80,
              margin: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  const SizedBox(width: 75),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(child: SizedBox()),
                        Text(
                          area ?? "",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          zone ?? "",
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      context.goNamed(
                        'Audits Page',
                        pathParameters: {
                          'zone': zone ?? "",
                          'area': area ?? "",
                        },
                        extra: color,
                      );
                    },
                    iconSize: 50.0,
                  ),
                ],
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(
                  "lib/assets/images/vino.jpg",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}