import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_appbar.dart'
    show AdminAppBar;
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_navbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/area_item.dart';
import 'package:flutter_app_5s/utils/global_states/id_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AreaMenu extends StatefulWidget {
  const AreaMenu({super.key});

  @override
  State<AreaMenu> createState() => _AreaMenuState();
}

class _AreaMenuState extends State<AreaMenu> {
  List<Map<String, dynamic>> areas = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idProvider = Provider.of<IdProvider>(context, listen: false);
      if (idProvider.orgId == null) {
        context.goNamed('OrgMenu');
      }
    });
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    final idProvider = Provider.of<IdProvider>(context, listen: false);
    final orgId = idProvider.orgId;

    if (orgId == null) {
      setState(() {
        errorMessage = 'Organización no encontrada';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/org/$orgId/area'),
        headers: {'Authorization': 'Bearer ...'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        debugPrint('Datos recibidos: ${data.length}');
        setState(() {
          areas = data
              .map((item) => {
                    'id': item['id'].toString(),
                    'name': item['name'] ?? '',
                    'description': item['description'] ?? '',
                    'logoUrl': item['logoUrl'] ?? '',
                  })
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error ${response.statusCode}';
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
    final colorScheme = Theme.of(context).colorScheme;
    if (isLoading) {
      return const  Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }
    return Scaffold(
      appBar: AdminAppBar(
        title: "Areas",
        onBackPressed: () {
          IdProvider().clearOrgId();
          context.pushNamed(
            'AdminDashboard',
          );
        },
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Container(
                color: colorScheme.surface,
                child: ListView(
                  children: [
                    ...areas
                        .map((area) => AreaItem(
                              id: area['id'],
                              name: area['name'],
                              description: area['description'],
                              logoUrl: area['logoUrl'],
                              onTap: () => _handleDepartmentTap(area['id']),
                            ))
                        .toList(),
                  ],
                )),
          ),
          const AdminNavBar(),
        ],
      ),
    );
  }

  void _handleDepartmentTap(String id) {
    final idProvider = Provider.of<IdProvider>(context, listen: false);
    idProvider.setAreaId(id);

    context.pushNamed(
      'AddSubArea',
    );
  }
}
