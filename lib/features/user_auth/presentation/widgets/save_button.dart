import 'package:flutter/material.dart';

class SaveButton extends StatefulWidget {
  final List<String> saveStates;
  final Function(String) onSave;
  const SaveButton({super.key, required this.saveStates, required this.onSave});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  String? _selectedState;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
