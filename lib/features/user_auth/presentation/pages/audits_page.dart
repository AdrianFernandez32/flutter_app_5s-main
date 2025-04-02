import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FilterSettings {
  int? ratingFilter;
  String? dateFilter;
}

class AuditsPage extends StatefulWidget {
  final String zone;
  final String area;
  final Color color;

  const AuditsPage(
      {Key? key, required this.zone, required this.color, required this.area})
      : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<AuditsPage> createState() => _AuditsPageState(
        zone: zone,
        color: color,
        area: area,
      );
}

class _AuditsPageState extends State<AuditsPage> {
  final String zone;
  final String area;
  final Color color;

  FilterSettings filterSettings = FilterSettings();
  List<AreaWidget> audits = [];

  _AuditsPageState(
      {required this.zone, required this.color, required this.area});

  @override
  void initState() {
    super.initState();
    final Random random = Random();
    final List<double> progressList = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 5, 22);

    for (int i = 0; i < 10; i++) {
      final progress = progressList[random.nextInt(progressList.length)];
      final randomDate = startDate.add(
          Duration(days: random.nextInt(endDate.difference(startDate).inDays)));
      final date =
          "${randomDate.day.toString().padLeft(2, '0')}/${randomDate.month.toString().padLeft(2, '0')}/${randomDate.year}";

      audits.add(AreaWidget(
        zone: zone,
        date: date,
        progress: progress,
        color: color,
        area: area,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: colorScheme.secondary,
        title: const Text(
          "Auditar",
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
            color: const Color.fromRGBO(134, 75, 111, 1),
            height: 2,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<int>(
                  value: filterSettings.ratingFilter,
                  onChanged: (newValue) {
                    setState(() {
                      filterSettings.ratingFilter = newValue;
                    });
                  },
                  items: const [
                    DropdownMenuItem<int>(
                      value: null,
                      child: Text("Calificacion"),
                    ),
                    DropdownMenuItem<int>(
                      value: 50,
                      child: Text("50+"),
                    ),
                    DropdownMenuItem<int>(
                      value: 80,
                      child: Text("80+"),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: filterSettings.dateFilter,
                  onChanged: (newValue) {
                    setState(() {
                      filterSettings.dateFilter = newValue;
                    });
                  },
                  items: _buildDateDropdownItems(),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: _buildFilteredAreaWidgets(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDateDropdownItems() {
    final List<DropdownMenuItem<String>> items = [];
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 5, 22);

    for (DateTime date = startDate;
        date.isBefore(endDate);
        date = date.add(const Duration(days: 1))) {
      final formattedDate =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      items.add(DropdownMenuItem<String>(
        value: formattedDate,
        child: Text(formattedDate),
      ));
    }

    items.insert(
      0,
      const DropdownMenuItem<String>(
        value: null,
        child: Text("Fecha"),
      ),
    );

    return items;
  }

  List<Widget> _buildFilteredAreaWidgets() {
    List<Widget> widgets = [];
    for (final audit in audits) {
      if (_filterByRating(audit.progress) && _filterByDate(audit.date)) {
        widgets.add(
          Column(
            children: [
              AreaWidget(
                zone: audit.zone,
                date: audit.date,
                progress: audit.progress,
                color: audit.color,
                area: area,
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      }
    }
    return widgets;
  }

  bool _filterByRating(double progress) {
    if (filterSettings.ratingFilter == null) {
      return true;
    } else {
      return progress >= filterSettings.ratingFilter!;
    }
  }

  bool _filterByDate(String date) {
    if (filterSettings.dateFilter == null) {
      return true;
    } else {
      return date == filterSettings.dateFilter!;
    }
  }
}

class AreaWidget extends StatelessWidget {
  final String zone;
  final String date;
  final String area;
  final double progress;
  final Color color;

  const AreaWidget({
    Key? key,
    required this.zone,
    required this.date,
    required this.progress,
    required this.color,
    required this.area,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 20, 0),
      child: GestureDetector(
        onTap: () {
          context.goNamed('Auditorias',
              pathParameters: {
                'zona': zone,
                'auditDate': date,
                'area': area,
              },
              extra: color);
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
                          zone,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Expanded(child: SizedBox()),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Expanded(child: SizedBox()),
                        const Text(
                          "Completada",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(
                        8.0,
                      ),
                      child: _buildProgressIcon(progress),
                    ),
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

  Widget _buildProgressIcon(double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            color: _getProgressColor(progress),
            shape: BoxShape.circle,
          ),
        ),
        Text(
          (progress).toInt().toString(),
          style: const TextStyle(
            fontSize: 30.0,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 50) {
      return const Color.fromARGB(255, 208, 34, 34);
    } else if (progress < 80) {
      return const Color.fromARGB(255, 220, 193, 1);
    } else {
      return const Color.fromARGB(255, 25, 187, 79);
    }
  }
}
