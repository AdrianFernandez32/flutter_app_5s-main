import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_appbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_navbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/five_s_card.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/rounded_button.dart';
import 'package:go_router/go_router.dart';

class FiveSMenu extends StatelessWidget {
  final String departmentId;
  static const List<String> fiveSTitles = [
    "Seiri",
    "Seiton",
    "Seiso",
    "Seiketsu",
    "Shitsuke"
  ];
  const FiveSMenu({
    super.key,
    required this.departmentId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AdminAppBar(
        title: "5S",
        onBackPressed: () {
          context.pushNamed(
            'AddDepartment',
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
                  ...fiveSTitles
                      .map((s) => FiveSCard(
                          title: s, onTap: () => _handleSTap(context, s)))
                      .toList(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RoundedButton(
                        context: context,
                        label: "Editar",
                        onPressed: () => _handleEdit()),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RoundedButton(
                        context: context,
                        label: "Eliminar",
                        onPressed: () => _handleDelete()),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSTap(BuildContext context, String s) {
    context.pushNamed(
      'QuestionnaireAdminMenu',
      pathParameters: {'departmentId': departmentId, 'fiveSId': s},
    );
  }

  void _handleEdit() {
    print("Editar $departmentId");
  }

  void _handleDelete() {
    print("Eliminar $departmentId");
  }
}