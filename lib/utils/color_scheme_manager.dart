import 'dart:ui';

import 'package:flutter/material.dart';

// Enum with the names of the different color palettes
enum PaletteType { defaultColor, blue, purple, green, wine }

// Class that holds the color palettes
class ColorPalette {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;

  const ColorPalette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
  });

  // Method to get the color palette based on the palette type
  // If the palette type is not found, it will return the default color palette
  // If you want to add a new color palette you need a convertor from hex color to Color(int) special class of flutter
  static ColorPalette getPalette(PaletteType type) {
    switch (type) {
      case PaletteType.blue:
        return const ColorPalette(
          primary: Color(0xFF1C4243),
          secondary: Color(0xFF008686),
          accent: Color(0xFF3AB8B7),
          background: Color(0xFFE8EEEE),
        );
      case PaletteType.purple:
        return const ColorPalette(
          primary: Color(0xFF39395A),
          secondary: Color(0xFF6767D0),
          accent: Color(0xFF9C9CF2),
          background: Color(0xFFEDEDF1),
        );
      case PaletteType.green:
        return const ColorPalette(
          primary: Color(0xFF2A3A1D),
          secondary: Color(0xFF2DAA60),
          accent: Color(0xFF67D08E),
          background: Color(0xFFE8EEEE),
        );
      case PaletteType.wine:
        return const ColorPalette(
          primary: Color(0xFF333333),
          secondary: Color(0xFF8E2C8C),
          accent: Color(0xFFB8A285),
          background: Color(0xFFF5F5F5),
        );
      default:
        return const ColorPalette(
          primary: Color(0xFF1F3D58),
          secondary: Color(0xFF077DCD),
          accent: Color(0xFF42B0F1),
          background: Color(0xFFE8EEF1),
        );
    }
  }
}
