import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddDepartment extends StatelessWidget {
  const AddDepartment({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Agregar departamentos",
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
      ),
      body: Container(
          color: colorScheme.surface,
          child: Column(
            children: [],
          )),
    );
  }
}
