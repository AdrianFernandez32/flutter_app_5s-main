import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app_5s/utils/color_scheme_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_5s/auth/auth_service.dart';

class CreateOrganizationPage extends StatefulWidget {
  const CreateOrganizationPage({Key? key}) : super(key: key);

  @override
  _CreateOrganizationPageState createState() => _CreateOrganizationPageState();
}

class _CreateOrganizationPageState extends State<CreateOrganizationPage> {
  File? _image;
  PaletteType selectedPalette = PaletteType.blue;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  // Método para seleccionar imagen desde la galería.
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  // Método que usa el presigned URL para subir la imagen a S3.
  Future<String> _uploadImage(File imageFile) async {
    try {
      // Obtener el token JWT del AuthService
      final authService = AuthService();
      final accessToken = authService.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No has iniciado sesión.');
      }
      // 1. Obtener la URL pre-firmada desde el endpoint
      final presignedUri = Uri.parse(
          'https://djnxv2fqbiqog.cloudfront.net/image/presigned-url/${_nameController.text}');
      final presignedResponse = await http.get(
        presignedUri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (presignedResponse.statusCode != 200) {
        throw Exception(
            'Error al obtener la URL pre-firmada: ${presignedResponse.statusCode}');
      }

      final presignedUrl = presignedResponse.body.trim();

      if (presignedUrl.isEmpty) {
        throw Exception('La URL pre-firmada está vacía.');
      }

      // 2. Leer los bytes de la imagen
      final imageBytes = await imageFile.readAsBytes();

      // 3. Subir la imagen con un PUT a la URL pre-firmada
      final putResponse = await http.put(
        Uri.parse(presignedUrl),
        headers: {
          'Content-Type':
              'image/jpeg', // Asegúrate de que el tipo MIME sea correcto
        },
        body: imageBytes,
      );

      if (putResponse.statusCode != 200 && putResponse.statusCode != 201) {
        throw Exception('Error al subir la imagen: ${putResponse.statusCode}');
      }

      // 4. Retornar la URL final de la imagen (sin parámetros de query)
      final finalImageUrl = presignedUrl.split('?').first;
      return finalImageUrl;
    } catch (e) {
      throw Exception('Error en la carga de la imagen: $e');
    }
  }

  // Método que crea la organización. Si se subió imagen se incluye el URL real, de lo contrario, se envía como vacía.
  Future<void> _createOrganization() async {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    // Obtener el token JWT del AuthService
    final authService = AuthService();
    final accessToken = authService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No has iniciado sesión.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Subir imagen si se seleccionó. Sino, logoUrl quedará en blanco.
      String logoUrl = '';
      if (_image != null) {
        logoUrl = await _uploadImage(_image!);
      }

      // Armar payload para el POST.
      final uri = Uri.parse('https://djnxv2fqbiqog.cloudfront.net/org/');
      final payload = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'colorPalette': selectedPalette.name,
        'logoUrl': logoUrl,
      };
      final body = jsonEncode(payload);

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organización creada exitosamente')),
        );
        context.goNamed('Menu');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error: \\${response.statusCode} - \\${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AbsorbPointer(
              absorbing: _isLoading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 95,
                            backgroundColor: Colors.blue,
                            child: CircleAvatar(
                              radius: 92,
                              backgroundColor: Colors.grey[200],
                              backgroundImage:
                                  _image != null ? FileImage(_image!) : null,
                              child: _image == null
                                  ? const Icon(Icons.add,
                                      size: 50, color: Colors.blue)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _image == null ? "Agregar foto" : "Cambiar foto",
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Agregar nombre de organización",
                            hintStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownMenu<PaletteType>(
                          width: 400,
                          initialSelection: selectedPalette,
                          onSelected: (PaletteType? newValue) {
                            if (newValue != null) {
                              setState(() => selectedPalette = newValue);
                            }
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(
                                value: PaletteType.blue, label: "Blue"),
                            DropdownMenuEntry(
                                value: PaletteType.purple, label: "Purple"),
                            DropdownMenuEntry(
                                value: PaletteType.green, label: "Green"),
                            DropdownMenuEntry(
                                value: PaletteType.wine, label: "Wine"),
                            DropdownMenuEntry(
                                value: PaletteType.blue, label: "Default"),
                          ],
                          inputDecorationTheme: InputDecorationTheme(
                            hintStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Añade una descripción",
                            hintStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _createOrganization,
                      child: const Text(
                        "Crear",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
