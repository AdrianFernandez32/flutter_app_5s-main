import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/main_menu.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/organizations_list_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/acceso_admin.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ajustes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showTutorials = false;
  bool _showFAQ = false;
  int? _expandedQuestionIndex;

  Future<void> _openPdf(String pdfName) async {
    try {
      final byteData = await rootBundle.load('assets/docs/$pdfName');
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$pdfName';
      final file = File(tempPath);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      final result = await OpenFile.open(tempPath);

      if (result.type != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el PDF')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir el documento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.goNamed('Menu'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Carlos Trasviña',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jefe de Área',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Zona Operativa Embotellado',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(thickness: 1, color: Colors.grey),
                ],
              ),
            ),
            _buildSectionHeader(
              icon: Icons.play_circle_outline,
              title: 'Tutoriales',
              isExpanded: _showTutorials,
              onTap: () => setState(() => _showTutorials = !_showTutorials),
            ),
            if (_showTutorials) ...[
              _buildMenuItem(
                Icons.assignment,
                'Crear Cuestionarios',
                onTap: () => _openPdf('Crear_Cuestionarios(AURIS).pdf'),
              ),
              _buildMenuItem(
                Icons.assessment,
                'Hacer Auditorías',
                onTap: () => _openPdf('Hacer_Auditorias(AURIS).pdf'),
              ),
              _buildMenuItem(
                Icons.people_alt,
                'Asignar Usuarios a Áreas',
                onTap: () => _openPdf('Asignar_Usuario(AURIS).pdf'),
              ),
              _buildMenuItem(
                Icons.help_outline,
                'FAQ',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'El manual de FAQ no está disponible actualmente'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
            _buildSectionHeader(
              icon: Icons.question_answer,
              title: 'FAQ',
              isExpanded: _showFAQ,
              onTap: () => setState(() => _showFAQ = !_showFAQ),
            ),
            if (_showFAQ) ...[
              _buildFAQItem(
                0,
                '¿Qué hago si no veo mis áreas o usuarios?',
                'Verifica tu rol y permisos. Si el problema continúa, contacta al administrador del sistema.\n\nCorreo: auris.apoyo@gmail.com',
              ),
              _buildFAQItem(
                1,
                '¿Qué significan las 5S en la app?',
                'Las 5S representan las fases del método japonés: Seiri, Seiton, Seiso, Seiketsu, Shitsuke. Cada S tiene un grupo de preguntas dentro del cuestionario.',
              ),
              _buildFAQItem(
                2,
                '¿Cómo puedo crear una nueva organización en la app?',
                'Solo los usuarios con permisos de Administrador pueden crear organizaciones. Para hacerlo:\n\n'
                    '1. Dirígete al panel principal de administración.\n'
                    '2. Selecciona la opción "Crear Organización".\n'
                    '3. Ingresa el nombre, descripción, paleta de colores y una imagen de perfil.\n'
                    '4. Guarda los cambios y asigna usuarios y cuestionarios.',
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  // Si tienes AuthService, limpia la sesión aquí
                  // AuthService().logout();
                  context.goNamed('AdminAccessPage');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[600]),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.blue,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQItem(int index, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          _expandedQuestionIndex == index
              ? Icons.expand_less
              : Icons.expand_more,
          color: Colors.blue,
        ),
        initiallyExpanded: _expandedQuestionIndex == index,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedQuestionIndex = expanded ? index : null;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[800], size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const Spacer(),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.blue[800],
            ),
          ],
        ),
      ),
    );
  }
}
