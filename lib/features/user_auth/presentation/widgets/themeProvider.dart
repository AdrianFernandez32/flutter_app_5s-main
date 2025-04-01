import 'package:flutter/material.dart';
import 'package:flutter_app_5s/utils/color_scheme_manager.dart';

class ThemeProvider extends ChangeNotifier {
  PaletteType _currentPallete = PaletteType.defaultColor;

  PaletteType get currentPallete => _currentPallete;
  ColorPalette get colors => ColorPalette.getPalette(_currentPallete);

  void changePalette(PaletteType newPalette) {
    _currentPallete = newPalette;
    notifyListeners();
  }
}
