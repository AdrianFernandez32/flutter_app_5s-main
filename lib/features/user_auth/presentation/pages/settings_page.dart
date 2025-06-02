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
          children: const [],
        ),
      ),
    );
  }
}
