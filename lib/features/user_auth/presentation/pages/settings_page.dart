// import 'package:flutter/material.dart';
// import 'package:flutter_app_5s/features/user_auth/presentation/widgets/user_basic_info.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({Key? key}) : super(key: key);

//   @override
//   SettingsPageState createState() => SettingsPageState();
// }

// class SettingsPageState extends State<SettingsPage> {
//   @override
//   Widget build(BuildContext context) {
//     const color = Color.fromRGBO(79, 67, 73, 1);

//     // Datos simulados de un fetch
//     const Map<String, String> response = {
//       "id": "1",
//       "username": "Carlos Trasviña",
//       "rol": "Jefe de Área",
//       "zone": "Zona Operativa",
//       "area": "Embotellado"
//     };

//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           toolbarHeight: 80,
//           backgroundColor: const Color.fromRGBO(240, 222, 229, 1),
//           title: const Text(
//             "Ajustes",
//             style: TextStyle(color: color, fontSize: 32),
//           ),
//           leading: IconButton(
//               onPressed: () {
//                 context.goNamed("Menu");
//               },
//               icon: const Icon(
//                 Icons.arrow_back,
//                 color: color,
//                 size: 33,
//               )),
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(50),
//             child: Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     color: const Color.fromRGBO(134, 75, 111, 1),
//                     height: 2,
//                   ),
//                   const TabBar(indicatorSize: TabBarIndicatorSize.tab, tabs: [
//                     Tab(
//                       text: "General",
//                     ),
//                     Tab(
//                       text: "Tutoriales",
//                     ),
//                     Tab(
//                       text: "FAQ",
//                     ),
//                   ]),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         body: TabBarView(children: [
//           // General
//           SingleChildScrollView(
//             child: Column(children: [
//               Center(
//                 child: Container(
//                   padding: const EdgeInsets.only(top: 12, bottom: 12),
//                   child: UserBasicInfo(
//                     username: response["username"],
//                     area: response["area"],
//                     rol: response["rol"],
//                     zone: response["zone"],
//                   ),
//                 ),
//               ),
//               // Terminos de Privacidad (sin notificaciones)
//               Center(
//                 child: Container(
//                   padding: const EdgeInsets.only(top: 12, bottom: 12),
//                   child: Row(
//                     children: [
//                       const SizedBox(
//                         width: 20,
//                       ),
//                       Expanded(
//                           child: Container(
//                         padding: const EdgeInsets.only(
//                             top: 12, bottom: 12, left: 20, right: 20),
//                         decoration: const BoxDecoration(
//                             borderRadius: BorderRadius.all(Radius.circular(20)),
//                             color: Color.fromRGBO(240, 222, 229, 1)),
//                         child: const Row(
//                           children: [
//                             Expanded(
//                               child: SizedBox(),
//                             ),
//                             Icon(
//                               Icons.attach_file,
//                               color: Color.fromRGBO(134, 75, 111, 1),
//                             ),
//                             Text(
//                               "Terminos de Privacidad",
//                               style: TextStyle(
//                                   color: Color.fromRGBO(134, 75, 111, 1),
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 16),
//                             ),
//                             Expanded(
//                               child: SizedBox(),
//                             )
//                           ],
//                         ),
//                       )),
//                       const SizedBox(
//                         width: 20,
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.only(top: 20, bottom: 20),
//                 child: Center(
//                   child: TextButton(
//                     onPressed: () async {
//                       await Supabase.instance.client.auth.signOut();
//                       context.goNamed("SplashScreen");
//                     },
//                     child: const Text(
//                       "Cerrar Sesión",
//                       style: TextStyle(
//                           color: Color.fromRGBO(134, 75, 111, 1),
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20),
//                     ),
//                   ),
//                 ),
//               )
//             ]),
//           ),

//           // Tutoriales
//           const SingleChildScrollView(
//             child: Column(
//               children: [
//                 Text("Tutoriales"),
//               ],
//             ),
//           ),

//           // FAQ
//           const SingleChildScrollView(
//             child: Column(
//               children: [
//                 Text("Preguntas Frecuentes"),
//               ],
//             ),
//           )
//         ]),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

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
          onPressed: () => Navigator.pop(context),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
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
              _buildMenuItem(Icons.help_outline, 'FAQ'),
              _buildMenuItem(Icons.assignment, 'Crear Cuestionarios'),
              _buildMenuItem(Icons.assessment, 'Hacer Auditorías'),
              _buildMenuItem(Icons.people_alt, 'Asignar Usuarios a Áreas'),
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
                'Verifica tu rol y permisos. Si el problema continúa, contacta al administrador del sistema.',
              ),
              _buildFAQItem(
                1,
                '¿Qué significan las 5S en la app?',
                'Las 5S representan las fases del método japonés: Seiri, Seiton, Seiso, Seiketsu, Shitsuke. '
                    'Cada S tiene un grupo de preguntas dentro del cuestionario.',
              ),
              _buildFAQItem(
                2,
                '¿Cómo puedo crear una nueva organización en la app?',
                'Solo los usuarios con permisos de Administrador pueden crear organizaciones. Para hacerlo:\n\n'
                    '1. Dirígete al panel principal de administración.\n\n'
                    '2. Selecciona la opción "Crear Organización".\n\n'
                    '3. Ingresa el nombre, una descripción opcional y elige una paleta de colores y una foto de perfil que identifique visualmente a la organización.\n\n'
                    '4. Guarda los cambios. Luego podrás añadir departamentos, usuarios y cuestionarios específicos para esa organización.',
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue[800],
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.blue[800]!),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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

  Widget _buildMenuItem(IconData icon, String title) {
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
        onTap: () {},
      ),
    );
  }
}
