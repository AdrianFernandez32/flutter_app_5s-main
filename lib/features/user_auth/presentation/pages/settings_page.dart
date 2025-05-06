import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/user_basic_info.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    const color = Color.fromRGBO(140, 140, 140, 1);

    // Datos simulados de un fetch
    const Map<String, String> response = {
      "id": "1",
      "username": "Carlos Trasviña",
      "rol": "Jefe de Área",
      "zone": "Zona Operativa",
      "area": "Embotellado"
    };

    final colorScheme = Theme.of(context).colorScheme;
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
              color: const Color.fromRGBO(140, 140, 140, 1),
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
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Color.fromRGBO(240, 222, 229, 1)),
                        child: const Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Notificaciones",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color.fromRGBO(79, 67, 73, 1)),
                                  ),
                                ),
                                _SwitchExample(),
                              ],
                            ),
                            Divider(),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(),
                                ),
                                Icon(
                                  Icons.attach_file,
                                  color: Color.fromRGBO(134, 75, 111, 1),
                                ),
                                Text(
                                  "Terminos de Privacidad",
                                  style: TextStyle(
                                      color: Color.fromRGBO(134, 75, 111, 1),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                Expanded(
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
                      context.goNamed("AdminAccessPage");
                    },
                    child: const Text(
                      "Cerrar Sesión",
                      style: TextStyle(
                          color: Color.fromRGBO(134, 75, 111, 1),
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
  const _SwitchExample();

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
