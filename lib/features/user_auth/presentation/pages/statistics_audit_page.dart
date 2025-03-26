import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/bar_chart.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/radar_chart.dart';
import 'package:go_router/go_router.dart';

class StatisticsAuditPage extends StatelessWidget {
  final String zona;
  final String auditDate;
  final String area;
  final Color color;

  const StatisticsAuditPage({
    Key? key,
    required this.zona,
    required this.auditDate,
    required this.area,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: zona,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuditViewExample(
        zona: zona,
        auditDate: auditDate,
        area: area,
        color: color,
      ),
    );
  }
}

class AuditViewExample extends StatelessWidget {
  final String zona;
  final String auditDate;
  final String area;
  final Color color;

  const AuditViewExample({
    Key? key,
    required this.zona,
    required this.auditDate,
    required this.area,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appBarElementsColor = Color.fromRGBO(79, 67, 73, 1);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(240, 222, 229, 1),
          leading: IconButton(
            onPressed: () {
              context.go('/auditsPage/$zona/$area', extra: color);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color.fromRGBO(79, 67, 73, 1),
              size: 33,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                zona,
                style: const TextStyle(
                  color: appBarElementsColor,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                "Auditoría del: $auditDate",
                style: const TextStyle(
                  color: appBarElementsColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(10),
            child: Container(
              color: const Color.fromRGBO(134, 75, 111, 1),
              height: 2,
            ),
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: const TabBar(
                    tabs: [
                      Tab(text: "Radial"),
                      Tab(text: "Histograma"),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: const AuditViewState(),
        ),
      ),
    );
  }
}

class AuditViewState extends StatelessWidget {
  const AuditViewState({Key? key}) : super(key: key);

  final List<String> auditNames = const [
    "SEIRI",
    "SEITON",
    "SEISON",
    "SEIKETSU",
    "SHITSUKE",
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(
          height: screenHeight / 2.6,
          child: const TabBarView(
            children: [
              AspectRatio(
                aspectRatio: 1.5,
                child: RadarChartWidget(),
              ),
              AspectRatio(
                aspectRatio: 1.5,
                child: BarChartWidget(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SWidget(
                  index: index + 1,
                  name: auditNames[index],
                  value: (index + 1) * 17,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SWidget extends StatelessWidget {
  final int index;
  final String name;
  final int value;

  const SWidget({
    Key? key,
    required this.index,
    required this.name,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: _getProgressColor(value),
            ),
            height: 80,
            margin: const EdgeInsets.only(left: 15),
            child: Row(
              children: [
                const SizedBox(width: 75),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: SizedBox()),
                      Text(
                        "$name - $value",
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      LinearProgressIndicator(
                        value: value / 100,
                        color: _getProgressBarColor(value),
                        backgroundColor: Colors.white,
                        minHeight: 6.0,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    context.goNamed('Menu');
                  },
                  iconSize: 50.0,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildSIcon("${index}S"),
          ),
        ],
      ),
    );
  }

  Widget _buildSIcon(String label) {
    return Container(
      width: 80.0,
      height: 80.0,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(134, 75, 111, 1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 50.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress < 50) {
      return const Color.fromRGBO(255, 180, 171, 1);
    } else if (progress < 80) {
      return const Color.fromRGBO(255, 220, 193, 1);
    } else {
      return const Color.fromRGBO(174, 242, 197, 1);
    }
  }

  Color _getProgressBarColor(int progress) {
    if (progress < 50) {
      return const Color.fromARGB(255, 208, 34, 34);
    } else if (progress < 80) {
      return const Color.fromARGB(255, 195, 107, 41);
    } else {
      return const Color.fromARGB(255, 25, 187, 79);
    }
  }
}
