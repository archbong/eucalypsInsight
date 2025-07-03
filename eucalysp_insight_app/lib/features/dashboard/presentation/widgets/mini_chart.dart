import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MiniChart extends StatelessWidget {
  final List<double> values;
  final Color? lineColor;
  final double height;
  final double width;

  const MiniChart({
    super.key,
    required this.values,
    this.lineColor,
    this.height = 60,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: values.length.toDouble() - 1,
          minY: 0,
          maxY: values.reduce((a, b) => a > b ? a : b) * 1.2,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: values.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value);
              }).toList(),
              isCurved: true,
              color: lineColor ?? Theme.of(context).primaryColor,
              barWidth: 2,
              belowBarData: BarAreaData(show: false),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
