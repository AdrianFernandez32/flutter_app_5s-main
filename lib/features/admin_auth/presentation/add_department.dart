import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_appbar.dart'
    show AdminAppBar;
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_navbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/departmentItem.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AddDepartment extends StatefulWidget {
  const AddDepartment({super.key});

  @override
  State<AddDepartment> createState() => _AddDepartmentState();
}

class _AddDepartmentState extends State<AddDepartment> {
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

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    try {
      final response = await http.get(
          Uri.parse('${dotenv.env['API_URL']}/org/'),
          headers: {'Authorization': 'Bearer ...'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          departments = data
              .map((item) => {
                    'title': item['name'],
                    'id': item['id'].toString(),
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
            //TODO : Agregar funcionalidad
            print("Go to previous page");
          }),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Container(
                color: colorScheme.surface,
                child: ListView(
                  children: [
                    ...mockDepartments
                        .map((department) => DepartmentItem(
                              title: department['title'],
                              onTap: () =>
                                  _handleDepartmentTap(department['id']),
                            ))
                        .toList(),
                  ],
                )),
          ),
          const AdminNavBar(),
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
                onPressed: () {
                  print('Department added');
                },
                backgroundColor: colorScheme.secondary,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                )),
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
