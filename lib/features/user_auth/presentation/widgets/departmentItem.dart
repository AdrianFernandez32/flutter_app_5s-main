import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DepartmentItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const DepartmentItem({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Icon(
                    Icons.edit,
                    color: colorScheme.onSurface.withOpacity(0.6),
                    size: 20,
                  ),
                  const SizedBox(
                    width: 12,
                  )
                ],
              ),
            ),
            Positioned(
              right: 16,
              top: 12,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
