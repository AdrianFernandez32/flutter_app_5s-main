import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/floating_plus_action_button.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/save_button.dart';

class AdminEditMenu extends StatelessWidget {
  final Function(String) onSave;
  final List<String> saveStates;
  final VoidCallback onPlusPressed;
  const AdminEditMenu({
    super.key,
    required this.onSave,
    required this.saveStates,
    required this.onPlusPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 30,
          left: 16,
          child: SaveButton(
            saveStates: saveStates,
            onSave: onSave,
          ),
        ),
        FloatingPlusActionButton(
          bottom: 30,
          onPressed: onPlusPressed,
        ),
      ],
    );
  }
}
