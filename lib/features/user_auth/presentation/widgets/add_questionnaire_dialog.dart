import 'package:flutter/material.dart';

class AddQuestionnaireDialog extends StatelessWidget {
  final Function(String) onSave;
  final TextEditingController _controller = TextEditingController();
  AddQuestionnaireDialog({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar cuestionario'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
            hintText: "Nombre del cuestionario", border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              onSave(_controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text('Crear'),
        )
      ],
    );
  }
}
