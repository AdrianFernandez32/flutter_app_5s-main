import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_appbar.dart'
    show AdminAppBar;
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_navbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/departmentItem.dart';

class AddDepartment extends StatelessWidget {
  const AddDepartment({super.key});
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
}

//TODO: Agregar funcionalidad
void _handleDepartmentTap(String id) {
  print('Department tapped ID: $id');
}
