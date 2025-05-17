import 'package:flutter/material.dart';
// Removed unused import
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.zero, // Ensure no extra padding
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                'https://phantom-marca-us.uecdn.es/67214b3666019836c0f2b41c2c48c1b3/resize/828/f/jpg/assets/multimedia/imagenes/2025/03/04/17410644450708.jpg'),
                            radius: 30,
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenido',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                'Carlos Trasviña',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 10, 16.0, 0),
                child: const Column(
                  children: [
                    _Button(
                      title: 'Auditar',
                      icon: Icons.library_add_check_outlined,
                      goToNamed: 'Auditar',
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    _Button(
                      title: 'Auditorías',
                      icon: Icons.file_copy_outlined,
                      goToNamed: 'Zones Page',
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    _Button(
                      title: 'Áreas',
                      icon: Icons.grid_view_outlined,
                      goToNamed: 'Gestion de Areas',
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    _Button(
                      title: 'Ajustes',
                      icon: Icons.settings_outlined,
                      goToNamed: 'Settings',
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    _Button(
                      title: 'Accesos',
                      icon: Icons.person,
                      goToNamed: 'Gestion de Accesos',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
          vertical: 17,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey, // Use black87 for a deeper black
            width: 1, // Adjust thickness
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
