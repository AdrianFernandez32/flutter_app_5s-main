import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBackPressed;

  const AdminAppBar({super.key, this.title, this.onBackPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onBackPressed ??
                  () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      Navigator.pop(context);
                    }
                  },
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colorScheme.onSecondary,
              ),
            ),
            const SizedBox(width: 16),
            if (title != null) // Corregido: eliminar las llaves {}
              Text(
                title!,
                style: TextStyle(
                  // Necesitas crear un TextStyle
                  color: colorScheme.onSecondary,
                  fontSize: 20, // Tamaño recomendado
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
