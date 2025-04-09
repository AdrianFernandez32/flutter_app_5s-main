import 'package:flutter/material.dart';

class FloatingPlusActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  const FloatingPlusActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: colorScheme.secondary,
          shape: const CircleBorder(),
          child: Icon(
            Icons.add,
            color: colorScheme.onSecondary,
          )),
    );
  }
}
