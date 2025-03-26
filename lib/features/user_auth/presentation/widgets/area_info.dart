import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AreaInfo extends StatelessWidget {
  final String? area;
  final String? zone;
  final Color color;
  final Color textColor;
  final String? areaID;
  final String? goToNamed;
  final bool? editButton;
  final Function? editButtonFuction;

  const AreaInfo(
      {Key? key,
      required this.area,
      required this.zone,
      required this.color,
      required this.areaID,
      required this.textColor,
      this.goToNamed,
      this.editButton,
      this.editButtonFuction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = this.color;
    Color textColor = this.textColor;
    String? area = this.area;
    String? zone = this.zone;
    String? areaID =
        this.areaID; // id que se tiene que mandar a la vista siguiente
    area ??= "";
    zone ??= "";
    areaID ??= "";
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: GestureDetector(
        onTap: () {
          // Aquí se tiene que revisar la lógica de enviar el id a la siguiente vista
          if (goToNamed != null) {
            context.goNamed(goToNamed ?? "Menu");
          }
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: color,
              ),
              height: 80,
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
                        const Expanded(child: SizedBox()),
                        Text(
                          area,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        Text(
                          zone,
                          style: TextStyle(fontSize: 13, color: textColor),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                  if (editButton ?? false || editButton == true)
                    IconButton.filled(
                      onPressed: () {
                        if (editButtonFuction == null) {
                          return;
                        }
                        editButtonFuction!();
                      },
                      icon: const Icon(Icons.edit_outlined),
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          Color.fromRGBO(134, 75, 111, 1),
                        ),
                      ),
                    ),
                  const SizedBox(
                    width: 12,
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
                  "lib/assets/images/vino.jpg",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
