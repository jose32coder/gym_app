import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class IngresosChart extends StatelessWidget {
  const IngresosChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var i = 0; i < 7; i++)
            BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (10 + i * 5).toDouble(), color: Colors.blue)]),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                return Text(days[value.toInt()]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
