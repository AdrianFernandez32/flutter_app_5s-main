import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app_5s/utils/global_states/id_provider.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBackPressed;

  const AdminAppBar({super.key, this.title, this.onBackPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final idProvider = Provider.of<IdProvider>(context, listen: false);

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
              onPressed: onBackPressed ?? () {
                idProvider.clearOrgId(); // Limpia el estado al retroceder
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed('AdminDashboard');
                }
              },
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colorScheme.onSecondary,
              ),
            ),
            const SizedBox(width: 16),
            if (title != null)
              Text(
                '${title!} - ${idProvider.orgId != null && idProvider.orgId!.isNotEmpty ? idProvider.orgId : "Sin ID"}',
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
