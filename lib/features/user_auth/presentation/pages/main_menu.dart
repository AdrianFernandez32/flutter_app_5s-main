import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/user_basic_info.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    // Simulando un fetch
    const Map<String, String> response = {
      "id": "1",
      "username": "Carlos Trasviña",
      "rol": "Jefe de Área",
      "zone": "Zona Operativa",
      "area": "Embotellado",
    };

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 42,
            ),
            const Center(
              child: Text(
                "Bienvenido",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 32),
              ),
            ),
            UserBasicInfo(
              username: response["username"]!,
              area: response["area"]!,
              rol: response["rol"]!,
              zone: response["zone"]!,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: const Column(
                children: [
                  _Button(
                    title: 'Auditar',
                    icon: Icons.library_add_check,
                    goToNamed: 'Auditar',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _Button(
                    title: 'Auditorías',
                    icon: Icons.file_copy,
                    goToNamed: 'Zones Page',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _Button(
                    title: 'Ajustes',
                    icon: Icons.settings,
                    goToNamed: 'Settings',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _Button(
                    title: 'Áreas',
                    icon: Icons.grid_view_rounded,
                    goToNamed: 'Gestion de Areas',
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 60,
            )
          ],
        ),
      ),
      floatingActionButton: const _SpeedDial(),
    );
  }
}

class _Button extends StatelessWidget {
  final String title;
  final IconData icon;
  final String goToNamed;

  const _Button({
    Key? key,
    required this.title,
    required this.icon,
    required this.goToNamed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.goNamed(goToNamed);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            12,
          ),
          color: const Color.fromARGB(
            255,
            255,
            220,
            193,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 70,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedDial extends StatefulWidget {
  const _SpeedDial({Key? key}) : super(key: key);

  @override
  _SpeedDialState createState() => _SpeedDialState();
}

class _SpeedDialState extends State<_SpeedDial> {
  bool selected = false;
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      backgroundColor: const Color.fromRGBO(243, 228, 233, 1),
      foregroundColor: const Color.fromRGBO(134, 75, 111, 1),
      spaceBetweenChildren: 12,
      animatedIcon: AnimatedIcons.menu_close,
      label: !selected ? const Text("Gestionar") : const SizedBox(),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      children: [
        SpeedDialChild(
          label: "Usuarios",
          labelBackgroundColor: const Color.fromRGBO(243, 228, 233, 1),
          labelStyle: const TextStyle(
              color: Color.fromRGBO(134, 75, 111, 1),
              fontWeight: FontWeight.w600),
          backgroundColor: const Color.fromRGBO(243, 228, 233, 1),
          foregroundColor: const Color.fromRGBO(134, 75, 111, 1),
          child: const Icon(Icons.person_outline_rounded),
          onTap: () {
            context.goNamed("Gestion de Usuarios");
          },
        ),
        SpeedDialChild(
          label: "Cuestionarios",
          labelBackgroundColor: const Color.fromRGBO(243, 228, 233, 1),
          labelStyle: const TextStyle(
              color: Color.fromRGBO(134, 75, 111, 1),
              fontWeight: FontWeight.w600),
          backgroundColor: const Color.fromRGBO(243, 228, 233, 1),
          foregroundColor: const Color.fromRGBO(134, 75, 111, 1),
          child: const Icon(Icons.folder),
          onTap: () {
            context.goNamed("Gestion de Cuestionarios");
          },
        )
      ],
    );
  }
}
