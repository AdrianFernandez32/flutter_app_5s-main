import 'package:flutter/material.dart';

class FloatingPlusActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double bottom;
  const FloatingPlusActionButton(
      {super.key, required this.onPressed, this.bottom = 100});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      bottom: bottom,
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
