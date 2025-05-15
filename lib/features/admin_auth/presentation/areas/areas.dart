import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_appbar.dart'
    show AdminAppBar;
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_navbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/area_item.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/floating_plus_action_button.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AreaMenu extends StatefulWidget {
  const AreaMenu({super.key});

  @override
  State<AreaMenu> createState() => _AreaMenuState();
}

class _AreaMenuState extends State<AreaMenu> {
  List<Map<String, dynamic>> areas = [];
  bool isLoading = true;
  String? errorMessage;
  int orgId = 1;

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
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
      return Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }
    return Scaffold(
      appBar: AdminAppBar(
        title: "Areas",
        onBackPressed: () {
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
          FloatingPlusActionButton(
            onPressed: () {
              //TODO : Agregar funcionalidad
              print("AddDepartment");
            },
          )
        ],
      ),
    );
  }

//TODO: Agregar funcionalidad
  void _handleDepartmentTap(String id) {
    context.pushNamed(
      'FiveSMenu',
      pathParameters: {'departmentId': id},
    );
  }
}
