import 'package:flutter/material.dart';

class UserBasicInfo extends StatelessWidget {
  final String? username;
  final String? rol;
  final String? zone;
  final String? area;

  const UserBasicInfo({
    Key? key,
    this.username,
    this.rol,
    this.zone,
    this.area,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Variables para checar nulos
    var usernameNotNull = username;
    var rolNotNull = rol;
    var zoneNotNull = zone;
    var areaNotNull = area;

    // Asignar valor a variables si son nulas
    usernameNotNull ??= "";
    rolNotNull ??= "";
    zoneNotNull ??= "";
    areaNotNull ??= "";

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      height: 200,
      child: Stack(
        children: [
          Container(
            height: 140,
            margin: const EdgeInsets.only(top: 30),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color:
                  const Color.fromARGB(255, 155, 155, 155), // Fondo gris claro
            ),
            child: Column(
              children: [
                Expanded(child: Container()),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usernameNotNull,
                          style: const TextStyle(
                            color:
                                Colors.black, // Cambiado a negro para contraste
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          rolNotNull,
                          style: const TextStyle(
                            color:
                                Colors.black, // Cambiado a negro para contraste
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: Container()),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          zoneNotNull,
                          style: const TextStyle(
                            color:
                                Colors.black, // Cambiado a negro para contraste
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          areaNotNull,
                          style: const TextStyle(
                            color:
                                Colors.black, // Cambiado a negro para contraste
                            fontSize: 11,
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          const Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 50,
              // La imagen la tiene que tomar de afuera
              backgroundImage: AssetImage(
                "lib/assets/images/perfil_fake.jpg",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
