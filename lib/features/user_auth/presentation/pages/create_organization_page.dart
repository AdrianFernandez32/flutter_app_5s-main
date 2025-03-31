import 'package:flutter/material.dart';

class CreateOrganizationPage extends StatelessWidget {
  const CreateOrganizationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Botón de agregar foto
            GestureDetector(
              onTap: () {
                // Acción para agregar foto
              },
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.blue,
                child: CircleAvatar(
                  radius: 95,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.add, size: 50, color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Agregar foto", style: TextStyle(color: Colors.blue)),

            const SizedBox(height: 30),
            TextField(
              decoration: InputDecoration(
                hintText: "Agregar nombre",
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.bold, // Negrita
                  color: Colors.grey, // Color opcional
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
              ),
            ),

            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                hintText: "Paleta de color",
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.bold, // Negrita
                  color: Colors.grey, // Color opcional
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
                suffixIcon:
                    const Icon(Icons.arrow_forward_ios, color: Colors.blue),
              ),
              readOnly: true,
              onTap: () {
                // Acción para abrir selector de colores
              },
            ),

            const SizedBox(height: 15),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Añade una descripción",
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.bold, // Negrita
                  color: Colors.grey, // Color opcional
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
              ),
            ),

            const Spacer(),
            // Botón "Crear"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  // Acción al presionar crear
                },
                child: const Text("Crear",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
