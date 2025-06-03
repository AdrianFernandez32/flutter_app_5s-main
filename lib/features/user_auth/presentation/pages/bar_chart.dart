import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class BarChartWidget extends StatelessWidget {
  final List<dynamic> audits;
  final dynamic selectedAudit;
  const BarChartWidget(
      {Key? key, required this.audits, required this.selectedAudit})
      : super(key: key);

  List<dynamic> _getBarData() {
    final data =
        (audits.isEmpty && selectedAudit != null) ? [selectedAudit] : audits;
    return data.map((audit) {
      final score = (audit['score'] ?? 0).toDouble();
      final date = audit['createdAt'] != null
          ? DateTime.tryParse(audit['createdAt'])
          : null;
      final label =
          date != null ? DateFormat('MMM. yyyy', 'es').format(date) : '';
      return _AuditBarData(
        label: label,
        value: score,
        color: score < 50
            ? const Color(0xFFD22222)
            : score < 80
                ? const Color(0xFFB6E2A1)
                : const Color(0xFFB6E2A1),
        isNA: audit['score'] == null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeDateFormatting('es'),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final barData = _getBarData();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: SizedBox(
            height: 260,
            width: double.infinity,
            child: SfCartesianChart(
              margin:
                  const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                axisLine: const AxisLine(width: 3, color: Colors.black),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 100,
                interval: 20,
                axisLine: const AxisLine(width: 3, color: Colors.black),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              series: <ColumnSeries<dynamic, String>>[
                ColumnSeries<dynamic, String>(
                  dataSource: barData,
                  xValueMapper: (dynamic data, _) => data.label,
                  yValueMapper: (dynamic data, _) =>
                      data.isNA ? null : data.value,
                  pointColorMapper: (dynamic data, _) =>
                      data.isNA ? const Color(0xFF888888) : data.color,
                  borderRadius: BorderRadius.circular(6),
                  width: 0.5,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.top,
                    textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  dataLabelMapper: (dynamic data, _) =>
                      data.isNA ? 'NA' : data.value.toInt().toString(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AuditBarData {
  final String label;
  final double value;
  final Color color;
  final bool isNA;
  _AuditBarData(
      {required this.label,
      required this.value,
      required this.color,
      this.isNA = false});
}
