import 'package:flutter/material.dart';

class ColorPaletteDropdown extends StatefulWidget {
  const ColorPaletteDropdown({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ColorPaletteDropdownState createState() => _ColorPaletteDropdownState();
}

class _ColorPaletteDropdownState extends State<ColorPaletteDropdown> {
  Color? selectedColor;

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Selecciona una paleta de color",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _colorOption(
                        [Colors.red[900]!, Colors.red, Colors.redAccent]),
                    const Divider(thickness: 1, height: 20),
                    _colorOption(
                        [Colors.blue[900]!, Colors.blue, Colors.lightBlue]),
                    const Divider(thickness: 1, height: 20),
                    _colorOption(
                        [Colors.green[900]!, Colors.green, Colors.lightGreen]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _colorOption(List<Color> colors) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = colors[1];
        });
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: colors.map((color) => _colorBox(color)).toList(),
      ),
    );
  }

  Widget _colorBox(Color color) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black54, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Paleta de color",
        hintStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
      ),
      readOnly: true,
      onTap: _showColorPicker,
    );
  }
}
