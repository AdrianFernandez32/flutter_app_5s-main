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
    // Ordenar por fecha descendente
    List<dynamic> sorted = List.from(audits);
    sorted.sort((a, b) {
      final aDate =
          a['createdAt'] != null && DateTime.tryParse(a['createdAt']) != null
              ? DateTime.parse(a['createdAt'])
              : DateTime(1970);
      final bDate =
          b['createdAt'] != null && DateTime.tryParse(b['createdAt']) != null
              ? DateTime.parse(b['createdAt'])
              : DateTime(1970);
      return bDate.compareTo(aDate);
    });
    // Tomar las 5 más recientes
    List<dynamic> recent = sorted.take(5).toList();
    // Buscar si la seleccionada está en la lista
    String? selectedId = selectedAudit != null && selectedAudit['id'] != null
        ? selectedAudit['id'].toString()
        : null;
    bool selectedInRecent = selectedId != null &&
        recent.any((a) => (a['id']?.toString() ?? '') == selectedId);
    // Si no está, agregarla
    if (!selectedInRecent && selectedAudit != null && selectedId != null) {
      // Buscar en audits para obtener la fecha si falta
      var found = audits.firstWhere(
        (a) => (a['id']?.toString() ?? '') == selectedId,
        orElse: () => selectedAudit,
      );
      recent.add(found);
      // Si hay más de 5, quitar la más vieja
      if (recent.length > 5) {
        recent.sort((a, b) {
          final aDate = a['createdAt'] != null &&
                  DateTime.tryParse(a['createdAt']) != null
              ? DateTime.parse(a['createdAt'])
              : DateTime(1970);
          final bDate = b['createdAt'] != null &&
                  DateTime.tryParse(b['createdAt']) != null
              ? DateTime.parse(b['createdAt'])
              : DateTime(1970);
          return bDate.compareTo(aDate);
        });
        recent = recent.take(5).toList();
      }
    }
    // Construir los datos para la gráfica
    return recent.map((audit) {
      final score = (audit['score'] ?? 0).toDouble();
      final createdAt = audit['createdAt'];
      String label = '';
      if (createdAt != null && DateTime.tryParse(createdAt) != null) {
        label = DateFormat('MMM. yyyy', 'es').format(DateTime.parse(createdAt));
      } else {
        label = 'Sin fecha';
      }
      final isSelected =
          selectedId != null && (audit['id']?.toString() ?? '') == selectedId;
      return _AuditBarData(
        label: label,
        value: score,
        color: isSelected
            ? const Color(0xFF1487D4) // Color destacado para la seleccionada
            : (score < 50
                ? const Color(0xFFD22222)
                : score < 80
                    ? const Color(0xFFB6E2A1)
                    : const Color(0xFFB6E2A1)),
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
        if (barData.isEmpty) {
          return const Center(
            child: Text('No hay datos válidos para mostrar.',
                style: TextStyle(fontSize: 18, color: Colors.black54)),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: SizedBox(
            height: 180,
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
                  yValueMapper: (dynamic data, _) => data.value,
                  pointColorMapper: (dynamic data, _) => data.color,
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
                      data.value.toInt().toString(),
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
  _AuditBarData({
    required this.label,
    required this.value,
    required this.color,
  });
}
