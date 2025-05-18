import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_appbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/org_item.dart';
import 'package:flutter_app_5s/utils/global_states/id_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OrgMenu extends StatefulWidget {
  const OrgMenu({super.key});

  @override
  State<OrgMenu> createState() => _OrgMenuState();
}

class _OrgMenuState extends State<OrgMenu> {
  List<Map<String, dynamic>> orgs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrgs();
  }

  Future<void> _fetchOrgs() async {
    try {
      final response = await http.get(
          Uri.parse('${dotenv.env['API_URL']}/org/'),
          headers: {'Authorization': 'Bearer ...'});

      if (response.statusCode == 200) {
        final List data = await jsonDecode(response.body);
        debugPrint('Datos recibidos: ${data.length}');
        setState(() {
          orgs = data.map((item) {
            final id = item['id']?.toString() ?? '';
            return {
              'id': id,
              'name': item['name'] ?? '',
              'colorPalette': item['colorPalette'] ?? '',
              'logoUrl': item['logoUrl'] ?? '',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error ${response.statusCode} ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Excepción: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final idProvider = Provider.of<IdProvider>(context);

    return Scaffold(
      appBar: AdminAppBar(
        title: 'Seleccionar Organización',
        onBackPressed: () {
          idProvider.clearOrgId();
          context.pushNamed('AdminDashboard');
        },
      ),
      body: ListView.builder(
        itemCount: orgs.length,
        itemBuilder: (context, index) => OrgItem(
            org: orgs[index],
          onTap: () {
            final orgId = orgs[index]['id'];
            if (orgId.isNotEmpty) {
              idProvider.setOrgId(orgId);
              context.pushNamed('AreaMenu');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error: ID de organización inválido"),
                  duration: Duration(seconds: 2),
                )
              );
            }
          },),
      ),
    );
  }
}
