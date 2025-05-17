import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_appbar.dart'
    show AdminAppBar;
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_navbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/subarea_item.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/floating_plus_action_button.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AddSubArea extends StatefulWidget {
  const AddSubArea({super.key});

  @override
  State<AddSubArea> createState() => _AddSubAreaState();
}

class _AddSubAreaState extends State<AddSubArea> {
  final List<Map<String, dynamic>> mockDepartments = const [
    {
      'title': 'Ventas',
      'id': '1',
    },
    {
      'title': 'Recursos Humanos',
      'id': '2',
    },
    {
      'title': 'Tecnología',
      'id': '3',
    },
    {
      'title': 'Marketing',
      'id': '4',
    },
  ];
  List<Map<String, dynamic>> departments = [];
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
          headers: {'Authorization': 'Bearer ...'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          departments = data
              .map((item) => {
                    'id': item['id'].toString(),
                    'title': item['name'],
                  })
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Error al cargar departamentos: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de conexión: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AdminAppBar(
        title: "Departamentos",
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
                    ...mockDepartments
                        .map((department) => SubAreaItem(
                              title: department['title'],
                              onTap: () =>
                                  _handleDepartmentTap(department['id']),
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
