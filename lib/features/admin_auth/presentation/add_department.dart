import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
      appBar: AppBar(
        title: Text(
          "Departamentos",
          style: TextStyle(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        centerTitle: true,
      ),
      body: Container(
          color: colorScheme.surface,
          child: ListView(
            children: [
              ...mockDepartments
                  .map((department) => DepartmentItem(
                        title: department['title'],
                        onTap: () => _handleDepartmentTap(department['id']),
                      ))
                  .toList()
            ],
          )),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            print('Department added');
          },
          backgroundColor: colorScheme.secondary,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          )),
    );
  }
}

void _handleDepartmentTap(String id) {
  print('Department tapped ID: $id');
}
