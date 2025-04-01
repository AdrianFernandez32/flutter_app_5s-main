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
          padding: EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Selecciona una paleta de color",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    _colorOption(
                        [Colors.blue[900]!, Colors.blue, Colors.lightBlue]),
                    _colorOption(
                        [Colors.teal[900]!, Colors.teal, Colors.tealAccent]),
                    _colorOption([
                      Colors.indigo[900]!,
                      Colors.indigo,
                      Colors.blueAccent
                    ]),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: colors.map((color) => _colorBox(color)).toList(),
        ),
      ),
    );
  }

  Widget _colorBox(Color color) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
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
