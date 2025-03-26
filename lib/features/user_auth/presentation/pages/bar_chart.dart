import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatefulWidget {
  const BarChartWidget({super.key});

  @override
  State<StatefulWidget> createState() => BarChartWidgetState();
}

class BarChartWidgetState extends State<BarChartWidget> {
  String getMonthName(int monthIndex) {
    List<String> months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];

    int index = (monthIndex - 1) % 12;
    return months[index];
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 9);
    String text = getMonthName(value.toInt() + 1);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    const style = TextStyle(
      fontSize: 10,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barsWidth = 8.0 * constraints.maxWidth / 100;
            return BarChart(
              BarChartData(
                alignment: BarChartAlignment.start,
                barTouchData: BarTouchData(
                  enabled: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: bottomTitles,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: leftTitles,
                      interval: 10.0,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  checkToShowHorizontalLine: (value) => value % 10 == 0,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Colors.red,
                    strokeWidth: 0.2,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                groupsSpace: 0.5,
                barGroups: getData(20, barsWidth),
              ),
            );
          },
        ),
      ),
    );
  }

  List<BarChartGroupData> getData(int count, double barsWidth) {
    List<BarChartGroupData> barChartGroups = [];
    Random random = Random();

    for (int i = 0; i < count; i++) {
      double randomValue = 10 + random.nextDouble() * 90;

      barChartGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: 101,
              rodStackItems: [
                BarChartRodStackItem(
                  0,
                  randomValue,
                  _getProgressBarColor(randomValue.toInt()),
                ),
              ],
              borderRadius: BorderRadius.zero,
              width: barsWidth,
              color: Colors.transparent,
            ),
          ],
        ),
      );
      if (barChartGroups.length > 10) {
        barChartGroups.removeAt(0);
      }
    }
    return barChartGroups;
  }

  Color _getProgressBarColor(int progress) {
    if (progress < 50) {
      return const Color.fromARGB(255, 208, 34, 34);
    } else if (progress < 80) {
      return const Color.fromARGB(255, 241, 162, 73);
    } else {
      return const Color.fromARGB(255, 25, 187, 79);
    }
  }
}
