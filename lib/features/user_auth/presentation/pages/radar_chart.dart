import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RadarChartWidget extends StatefulWidget {
  const RadarChartWidget({Key? key}) : super(key: key);

  @override
  RadarChartExampleState createState() => RadarChartExampleState();
}

class RadarChartExampleState extends State<RadarChartWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: RadarChart(
          RadarChartData(
            borderData: FlBorderData(
              show: false,
            ),
            radarBackgroundColor: Colors.transparent,
            radarBorderData: const BorderSide(
              color: Colors.black,
              width: 2,
            ),
            gridBorderData: const BorderSide(
              color: Colors.transparent,
            ),
            dataSets: showingDataSets(),
            ticksTextStyle: const TextStyle(
              color: Colors.transparent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            tickBorderData: const BorderSide(
              color: Colors.transparent,
            ),
            radarShape: RadarShape.polygon,
            tickCount: 100,
            titlePositionPercentageOffset: 0.05,
            getTitle: (index, angle) {
              switch (index) {
                case 0:
                  return const RadarChartTitle(
                    text: '1S',
                    angle: 0,
                  );
                case 1:
                  return const RadarChartTitle(
                    text: '2S',
                    angle: 0,
                  );
                case 2:
                  return const RadarChartTitle(
                    text: '3S',
                    angle: 0,
                  );
                case 3:
                  return const RadarChartTitle(
                    text: '4S',
                    angle: 0,
                  );
                case 4:
                  return const RadarChartTitle(
                    text: '5S',
                    angle: 0,
                  );
                default:
                  return const RadarChartTitle(text: '');
              }
            },
          ),
        ),
      ),
    );
  }

  List<RadarDataSet> showingDataSets() {
    return rawDataSets().asMap().entries.map((entry) {
      final rawDataSet = entry.value;

      return RadarDataSet(
        fillColor: rawDataSet.title == "eses"
            ? rawDataSet.color.withOpacity(0.7)
            : rawDataSet.color.withOpacity(0),
        borderColor: rawDataSet.color,
        entryRadius: rawDataSet.title == "eses" ? 3 : 0,
        dataEntries:
            rawDataSet.values.map((e) => RadarEntry(value: e)).toList(),
        borderWidth: rawDataSet.title == "eses" ? 3 : 1,
      );
    }).toList();
  }

  List<RawDataSet> rawDataSets() {
    return [
      RawDataSet(
        title: 'eses',
        color: Colors.red,
        values: [
          0,
          20,
          40,
          60,
          100,
        ],
      ),
      RawDataSet(
        title: 'test',
        color: Colors.transparent,
        values: [
          100,
          100,
          100,
          100,
          100,
        ],
      ),
      RawDataSet(
        title: 'test',
        color: Colors.transparent,
        values: [
          0,
          0,
          0,
          0,
          0,
        ],
      ),
      RawDataSet(
        title: 'test',
        color: Colors.grey,
        values: [
          20,
          20,
          20,
          20,
          20,
        ],
      ),
      RawDataSet(
        title: 'test',
        color: Colors.grey,
        values: [
          40,
          40,
          40,
          40,
          40,
        ],
      ),
      RawDataSet(
        title: 'test',
        color: Colors.grey,
        values: [
          60,
          60,
          60,
          60,
          60,
        ],
      ),
      RawDataSet(
        title: 'test',
        color: Colors.grey,
        values: [
          80,
          80,
          80,
          80,
          80,
        ],
      ),
    ];
  }
}

class RawDataSet {
  RawDataSet({
    required this.title,
    required this.color,
    required this.values,
  });

  final String title;
  final Color color;
  final List<double> values;
}
