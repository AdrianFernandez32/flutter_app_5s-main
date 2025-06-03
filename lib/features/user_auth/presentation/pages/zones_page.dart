import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app_5s/features/user_auth/presentation/pages/subareas_page.dart';
import 'package:flutter_app_5s/auth/auth_service.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/area_audits_page.dart';

class ZonesPage extends StatefulWidget {
  final bool modoHistorico;
  const ZonesPage({super.key, this.modoHistorico = false});

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
    final orgId = 55;
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
      return data.map<Map<String, dynamic>>((item) {
        return {
          "id": item["id"].toString(),
          "area": item["name"] ?? "",
          "zona": item["description"] ?? "",
        };
      }).toList();
    } else {
      throw Exception('Error al obtener las áreas: ${response.statusCode}');
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
              modoHistorico: widget.modoHistorico,
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
  final bool modoHistorico;

  const AuditWidget({
    Key? key,
    required this.area,
    required this.zone,
    required this.color,
    required this.areaID,
    required this.textColor,
    this.modoHistorico = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(214, 231, 239, 1),
        borderRadius: BorderRadius.circular(32),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AreaAuditsPage(
                areaId: int.tryParse(areaID ?? '') ?? 0,
                areaName: area ?? '',
                color: const Color(0xFF1487D4),
              ),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xFF1487D4),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    area ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    zone ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 32),
          ],
        ),
      ),
    );
  }
}
