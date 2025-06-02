import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_5s/auth/auth_service.dart';

class UserBasicInfo extends StatelessWidget {
  final String? username;
  final String? area;
  final String? rol;
  final String? zone;

  const UserBasicInfo({
    Key? key,
    this.username,
    this.area,
    this.rol,
    this.zone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: colorScheme.secondary,
            child: const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            username ?? 'Sin nombre',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rol ?? 'Sin rol',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${area ?? 'Sin área'} - ${zone ?? 'Sin zona'}',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const color = Color.fromRGBO(140, 140, 140, 1);

    // Datos simulados de un fetch
    const Map<String, String> response = {
      "id": "1",
      "username": "Carlos Trasviña",
      "rol": "Jefe de Área",
      "zone": "Zona Operativa",
      "area": "Embotellado"
    };

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: colorScheme.secondary,
          title: const Text(
            "Ajustes",
            style: TextStyle(color: Colors.white, fontSize: 32),
          ),
          leading: IconButton(
            onPressed: () {
              context.goNamed("Menu");
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 33,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(10),
            child: Container(
              color: colorScheme.secondary.withOpacity(0.5),
              height: 2,
            ),
          ),
        ),
        body: TabBarView(children: [
          // General
          SingleChildScrollView(
            child: Column(children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: UserBasicInfo(
                    username: response["username"],
                    area: response["area"],
                    rol: response["rol"],
                    zone: response["zone"],
                  ),
                ),
              ),
              const TabBar(indicatorSize: TabBarIndicatorSize.tab, tabs: [
                Tab(
                  text: "General",
                ),
                Tab(
                  text: "Tutoriales",
                ),
                Tab(
                  text: "FAQ",
                ),
              ]),
              // Notificaciones y Terminos de Privacidad
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          child: Container(
                        padding: const EdgeInsets.only(
                            top: 12, bottom: 12, left: 20, right: 20),
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            color: colorScheme.surface),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Notificaciones",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: colorScheme.onSurface),
                                  ),
                                ),
                                const _SwitchExample(),
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                const Expanded(
                                  child: SizedBox(),
                                ),
                                Icon(
                                  Icons.attach_file,
                                  color: colorScheme.secondary,
                                ),
                                Text(
                                  "Terminos de Privacidad",
                                  style: TextStyle(
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                const Expanded(
                                  child: SizedBox(),
                                )
                              ],
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Center(
                  child: TextButton(
                    onPressed: () async {
                      try {
                        await authService.logout();
                        if (!mounted) return;
                        context.goNamed("AdminAccessPage");
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al cerrar sesión: $e')),
                        );
                      }
                    },
                    child: Text(
                      "Cerrar Sesión",
                      style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
              )
            ]),
          ),

          // Tutoriales
          const SingleChildScrollView(
            child: Column(
              children: [
                Text("Tutoriales"),
              ],
            ),
          ),

          // FAQ

          const SingleChildScrollView(
            child: Column(
              children: [
                Text("Preguntas Frecuentes"),
              ],
            ),
          )
        ]),
      ),
    );
  }
}

class _SwitchExample extends StatefulWidget {
  const _SwitchExample({super.key});

  @override
  State<_SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<_SwitchExample> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: light,
      activeColor: const Color.fromRGBO(134, 75, 111, 1),
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          light = value;
        });
      },
    );
  }
}
//Se modifica
