import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MemberFoot extends StatelessWidget {
  const MemberFoot({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 40, color: Colors.blue, title: 'Premium'),
          PieChartSectionData(value: 30, color: Colors.green, title: 'Básica'),
          PieChartSectionData(value: 20, color: Colors.orange, title: 'Plus'),
          PieChartSectionData(value: 10, color: Colors.red, title: 'Trial'),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 30,
      ),
    );
  }
}
