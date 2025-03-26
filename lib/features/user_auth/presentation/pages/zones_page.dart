import 'package:flutter/material.dart';
import 'package:flutter_app_5s/utils/common.dart';
import 'package:go_router/go_router.dart';

class ZonesPage extends StatefulWidget {
  const ZonesPage({super.key});

  @override
  State<ZonesPage> createState() => _ZonesPageState();
}

class _ZonesPageState extends State<ZonesPage> {
  late Future<List<Map<String, dynamic>>> _areasFuture;

  @override
  void initState() {
    super.initState();
    _areasFuture = _fetchAreas();
  }

  Future<List<Map<String, dynamic>>> _fetchAreas() async {
    final response =
        await client.from('subarea').select('id, name, area!inner(name)');

    final data = response as List<dynamic>;
    return data.map((item) {
      final area = item['area'] as Map<String, dynamic>;
      return {
        "id": item['id'].toString(),
        "area": item['name'],
        "zona": area['name'],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const appBarElementsColor = Color.fromRGBO(79, 67, 73, 1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(240, 222, 229, 1),
        title: const Text(
          "Auditorías",
          style: TextStyle(color: appBarElementsColor, fontSize: 32),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Container(
            color: const Color.fromRGBO(134, 75, 111, 1),
            height: 2,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            context.goNamed("Menu");
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromRGBO(79, 67, 73, 1),
            size: 33,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _areasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No data found'),
            );
          }

          final responseList = snapshot.data!;
          List<Widget> areasList = [];

          for (int i = 0; i < responseList.length; i++) {
            Color color;
            Color textColor;

            switch (responseList[i]["zona"]) {
              case "Zona Operativa":
                color = const Color.fromRGBO(255, 216, 235, 1);
                textColor = const Color.fromRGBO(55, 7, 41, 1);
                break;
              case "Zona Soporte":
                color = const Color.fromRGBO(255, 220, 193, 1);
                textColor = const Color.fromRGBO(46, 21, 0, 1);
                break;
              case "Zona de Comunes":
                color = const Color.fromRGBO(174, 242, 197, 1);
                textColor = const Color.fromRGBO(0, 33, 16, 1);
                break;
              default:
                color = Colors.grey;
                textColor = Colors.black;
            }

            areasList.add(AuditWidget(
              area: responseList[i]["area"],
              zone: responseList[i]["zona"],
              color: color,
              areaID: responseList[i]["id"],
              textColor: textColor,
            ));
          }
          return ListView(
            children: areasList,
          );
        },
      ),
    );
  }
}

class AuditWidget extends StatelessWidget {
  final String? area;
  final String? zone;
  final Color color;
  final Color textColor;
  final String? areaID;

  const AuditWidget(
      {Key? key,
      required this.area,
      required this.zone,
      required this.color,
      required this.areaID,
      required this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = this.color;
    Color textColor = this.textColor;
    String? area = this.area;
    String? zone = this.zone;
    String? areaID = this.areaID;
    area ??= "";
    zone ??= "";
    areaID ??= "";
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: GestureDetector(
        onTap: () {
          context.goNamed(
            'Audits Page',
            pathParameters: {
              'zone': zone ?? "",
              'area': area ?? "",
            },
            extra: color,
          );
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
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          zone,
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      context.goNamed(
                        'Audits Page',
                        pathParameters: {
                          'zone': zone ?? "",
                          'area': area ?? "",
                        },
                        extra: color,
                      );
                    },
                    iconSize: 50.0,
                  ),
                ],
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                radius: 40,
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
