import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RadarChartWidget extends StatefulWidget {
  final List<dynamic> audits;
  final dynamic selectedAudit;
  const RadarChartWidget(
      {Key? key, required this.audits, required this.selectedAudit})
      : super(key: key);

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
    // El primer dataset es la auditoría seleccionada (azul), los demás son históricos (gris)
    List<RadarDataSet> sets = [];
    if (widget.selectedAudit != null) {
      sets.add(RadarDataSet(
        fillColor: Colors.blue.withOpacity(0.7),
        borderColor: Colors.blue,
        entryRadius: 3,
        dataEntries: _getSValues(widget.selectedAudit)
            .map((e) => RadarEntry(value: e))
            .toList(),
        borderWidth: 3,
      ));
    }
    for (final audit in widget.audits) {
      if (widget.selectedAudit != null &&
          audit['id'] == widget.selectedAudit['id']) continue;
      sets.add(RadarDataSet(
        fillColor: Colors.grey.withOpacity(0.2),
        borderColor: Colors.grey,
        entryRadius: 0,
        dataEntries:
            _getSValues(audit).map((e) => RadarEntry(value: e)).toList(),
        borderWidth: 1,
      ));
    }
    return sets;
  }

  List<double> _getSValues(dynamic audit) {
    final sKeys = ['S1', 'S2', 'S3', 'S4', 'S5'];
    if (audit == null || audit['s_scores'] == null) {
      return List.filled(5, 0.0);
    }
    return List<double>.from(
        sKeys.map((k) => (audit['s_scores'][k] ?? 0).toDouble()));
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
