import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final List<String> saveStates;
  final void Function(String) onSave;

  const SaveButton({
    super.key,
    required this.saveStates,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      onSelected: onSave,
      itemBuilder: (_) => saveStates
          .map((state) => PopupMenuItem<String>(
                value: state,
                child: Text(state),
              ))
          .toList(),
      // El Container va a fungir como tu “botón” personalizado
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.secondary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            // sombra sutil para que parezca flotante
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Guardar',
              style: TextStyle(
                color: scheme.onSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_drop_down,
              color: scheme.onSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
