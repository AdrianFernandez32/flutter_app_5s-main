import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appBarElementsColor = Color.fromRGBO(79, 67, 73, 1);

    List<Map<String, String>> response = [
      {
        "user": "Ramiro Nuñez Sanchez",
        "area": "Área de Embotellado",
        "zone": "Zona xxxx",
        "role": "Rol"
      },
      {
        "user": "Oscar Encinas",
        "area": "Área Asignada",
        "zone": "Zona xxxx",
        "role": "Rol"
      },
      {
        "user": "Carlos Trasviña Moreno",
        "area": "Área Asignada",
        "zone": "Zona xxxx",
        "role": "Rol"
      },
      {
        "user": "Usuario 4",
        "area": "Área Asignada",
        "zone": "Zona xxxx",
        "role": "Rol"
      },
      {
        "user": "Usuario 5",
        "area": "Área Asignada",
        "zone": "Zona xxxx",
        "role": "Rol"
      },
      {
        "user": "Usuario 6",
        "area": "Área Asignada",
        "zone": "Zona xxxx",
        "role": "Rol"
      },
      {
        "user": "Usuario 7",
        "area": "Área Asignada",
        "zone": "Zona xxxx",
        "role": "Rol"
      }
    ];

    List<Widget> usersList = [];

    for (var i = 0; i < response.length; i++) {
      usersList.insert(
          i,
          _AreasUsersInfo(
            name: response[i]["user"],
            area: response[i]["area"],
            zone: response[i]["zone"],
            role: response[i]["role"],
          ));
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromRGBO(240, 222, 229, 1),
        title: const Text(
          "Usuarios",
          style: TextStyle(color: appBarElementsColor, fontSize: 32),
        ),
        leading: IconButton(
            onPressed: () {
              context.goNamed("Menu");
            },
            icon: const Icon(
              Icons.arrow_back,
              color: appBarElementsColor,
              size: 33,
            )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Container(
            color: const Color.fromRGBO(134, 75, 111, 1),
            height: 2,
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
              Container(
                margin: const EdgeInsets.all(20),
                child: SearchBar(
                  onChanged: (value) {
                    // Falta lógica de búsqueda
                    // Pista: Modificar areasList y solo mostrar los que entren dentro de la búsqueda
                    print(value);
                  },
                  leading: const SizedBox(width: 50, child: Icon(Icons.search)),
                  hintText: "Buscar",
                ),
              ),
            ] +
            usersList +
            [
              const SizedBox(
                height: 40,
              )
            ],
      ),
    );
  }
}

class _AreasUsersInfo extends StatelessWidget {
  final String? name;
  final String? area;
  final String? zone;
  final String? role;

  const _AreasUsersInfo({Key? key, this.area, this.name, this.zone, this.role})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Color.fromRGBO(134, 75, 111, 1));
    const TextStyle textStyle2 =
        TextStyle(fontSize: 13, color: Color.fromRGBO(134, 75, 111, 1));
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(32)),
              color: const Color.fromRGBO(243, 228, 233, 1),
              border: Border.all(color: const Color.fromRGBO(134, 75, 111, 1)),
            ),
            height: 150,
            margin: const EdgeInsets.only(left: 15),
            child: Row(
              children: [
                const SizedBox(
                  width: 75,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        flex: 2,
                        child: SizedBox(),
                      ),
                      Text(name ?? "", style: textStyle),
                      const Expanded(child: SizedBox()),
                      Text(area ?? "", style: textStyle2),
                      const Expanded(child: SizedBox()),
                      Text(zone ?? "", style: textStyle2),
                      const Expanded(child: SizedBox()),
                      Text(role ?? "", style: textStyle2),
                      const Expanded(
                        flex: 3,
                        child: SizedBox(),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Color.fromRGBO(134, 75, 111, 1),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
              ],
            ),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
              radius: 40,
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
