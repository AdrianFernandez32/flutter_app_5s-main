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

  @override
  void initState() {
    super.initState();
    final authService = AuthService();
    print('JWT: ${authService.accessToken}');
  }

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
      final authService = AuthService();
      final accessToken = authService.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No has iniciado sesión.');
      }
      final presignedUri = Uri.parse(
          'https://djnxv2fqbiqog.cloudfront.net/image/presigned-url/${_nameController.text}');
      final presignedResponse = await http.get(
        presignedUri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (presignedResponse.statusCode != 200) {
        String msg = 'Error al obtener la URL pre-firmada: ${presignedResponse.statusCode}';
        try {
          final decoded = jsonDecode(presignedResponse.body);
          if (decoded is Map && decoded['message'] != null) {
            msg = decoded['message'];
          }
        } catch (_) {}
        throw Exception(msg);
      }
      final presignedUrl = presignedResponse.body.trim();
      if (presignedUrl.isEmpty) {
        throw Exception('La URL pre-firmada está vacía.');
      }
      final imageBytes = await imageFile.readAsBytes();
      final putResponse = await http.put(
        Uri.parse(presignedUrl),
        headers: {
          'Content-Type': 'image/jpeg',
        },
        body: imageBytes,
      );
      if (putResponse.statusCode != 200 && putResponse.statusCode != 201) {
        throw Exception('Error al subir la imagen: ${putResponse.statusCode}');
      }
      final finalImageUrl = presignedUrl.split('?').first;
      return finalImageUrl;
    } catch (e) {
      rethrow;
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
      String logoUrl = '';
      if (_image != null) {
        try {
          logoUrl = await _uploadImage(_image!);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir la imagen: $e')),
          );
          setState(() => _isLoading = false);
          return;
        }
      }
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
        },
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organización creada exitosamente')),
        );
        context.goNamed('OrganizationsListPage');
      } else {
        String msg = 'Error: ${response.statusCode}';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            msg = decoded['message'];
          } else if (decoded is String) {
            msg = decoded;
          }
        } catch (_) {
          msg = response.body;
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.goNamed('OrganizationsListPage');
          },
        ),
        title: const Text('Crear organización', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: AbsorbPointer(
              absorbing: _isLoading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: colorScheme.secondary,
                      child: CircleAvatar(
                        radius: 67,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? Icon(Icons.add, size: 40, color: colorScheme.secondary)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _image == null ? "Agregar foto" : "Cambiar foto",
                    style: TextStyle(color: colorScheme.secondary),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Agregar nombre de organización",
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: colorScheme.secondary, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: colorScheme.secondary, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: colorScheme.primary, width: 2),
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
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: colorScheme.secondary, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: colorScheme.secondary, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: colorScheme.primary, width: 2),
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
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: colorScheme.secondary, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: colorScheme.secondary, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: colorScheme.primary, width: 2),
                      ),
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
                  const SizedBox(height: 30),
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
