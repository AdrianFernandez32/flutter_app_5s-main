import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DepartmentItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const DepartmentItem({
    super.key,
    required this.title,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surface,
      child: ListTile(
        title: Text(title),
        onTap: onTap,
        trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface),
      ),
    );
  }
}
