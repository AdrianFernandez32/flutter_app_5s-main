import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccessesPage extends StatefulWidget {
  const AccessesPage({Key? key}) : super(key: key);

  @override
  AccesesPageState createState() => AccesesPageState();
}

class AccesesPageState extends State<AccessesPage> {
  @override
  Widget build(BuildContext context) {
    const textColorBlack = Color.fromRGBO(0, 0, 0, 1);
    const textColorWhite = Color.fromRGBO(255, 255, 255, 1);
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          backgroundColor: colorScheme.secondary,
          title: const Text(
            "Accesos",
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
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(10),
            child: Divider(
              thickness: 2,
              height: 2,
            ),
          ),
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.onSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 11),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botones de ordenamiento
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_drop_down),
                      label: const Text("Ordenar por"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.onSecondary,
                        foregroundColor: textColorBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_upward),
                      label: const Text("A-Z"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.onSecondary,
                        foregroundColor: textColorBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _userCard("Santiago Pérez", "03/04/26"),
                const SizedBox(height: 10),
                _userCard("Santiago Pérez", "03/04/26"),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 35,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: textColorWhite),
                label: const Text(
                  "Invitar",
                  style: TextStyle(color: textColorWhite),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userCard(String name, String joinDate) {
    const fontColor = Color.fromRGBO(0, 0, 0, 1);
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        context.goNamed('AccessesPageUsuario');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.onSecondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage:
                  AssetImage('assets/images/profile_placeholder.png'),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: fontColor,
                  ),
                ),
                Text(
                  "Se unió el: $joinDate",
                  style: const TextStyle(color: fontColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
