import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_5s/auth/auth_service.dart';

class AuditsPage extends StatefulWidget {
  final int subareaId;
  final String subareaName;
  final Color color;

  const AuditsPage({
    Key? key,
    required this.subareaId,
    required this.subareaName,
    required this.color,
  }) : super(key: key);

  @override
  State<AuditsPage> createState() => _AuditsPageState();
}

class _AuditsPageState extends State<AuditsPage> {
  late Future<List<dynamic>> _activeAuditsFuture;
  late Future<List<dynamic>> _historicAuditsFuture;

  @override
  void initState() {
    super.initState();
    _activeAuditsFuture = fetchAudits('active');
    _historicAuditsFuture = fetchAudits('historic');
  }

  Future<List<dynamic>> fetchAudits(String type) async {
    final authService = AuthService();
    final accessToken = authService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('No has iniciado sesión.');
    }
    final response = await http.get(
      Uri.parse(
          'https://djnxv2fqbiqog.cloudfront.net/audit/subarea/${widget.subareaId}/$type'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
          'Error al obtener auditorías ($type): ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: colorScheme.secondary,
        title: Text(
          widget.subareaName,
          style: const TextStyle(color: Colors.white, fontSize: 32),
        ),
        leading: IconButton(
          onPressed: () {
            context.goNamed("Zones Page");
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Auditorías en proceso',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<dynamic>>(
                future: _activeAuditsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay auditorías en proceso.');
                  }
                  return Column(
                    children: snapshot.data!
                        .map((audit) => AuditCard(
                            audit: audit,
                            color: widget.color,
                            status: 'En proceso'))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Auditorías completadas',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<dynamic>>(
                future: _historicAuditsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay auditorías completadas.');
                  }
                  return Column(
                    children: snapshot.data!
                        .map((audit) => AuditCard(
                            audit: audit,
                            color: widget.color,
                            status: 'Completada'))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuditCard extends StatelessWidget {
  final dynamic audit;
  final Color color;
  final String status;

  const AuditCard(
      {Key? key,
      required this.audit,
      required this.color,
      required this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress =
        (audit['questionsAnswered'] / (audit['totalQuestions'] ?? 1)) * 100;
    final date = audit['createdAt'] != null
        ? DateTime.tryParse(audit['createdAt'])
        : null;
    final formattedDate = date != null
        ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}"
        : "Sin fecha";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text('Fecha: $formattedDate'),
        subtitle: Text('Progreso: ${progress.toInt()}%'),
        trailing: Text(status,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: status == 'Completada' ? Colors.green : Colors.orange)),
      ),
    );
  }
}
