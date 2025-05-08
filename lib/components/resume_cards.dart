import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';

class ResumeCards extends StatelessWidget {
  const ResumeCards({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Colores para cada card según el tema
    final color1 = isDarkMode ? Colors.blue[700] : Colors.blue[100];
    final color2 = isDarkMode ? Colors.green[700] : Colors.green[100];
    final color3 = isDarkMode ? Colors.red[700] : Colors.red[100];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen General',
          style: TextStyles.boldText(context),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                width: screenWidth * 0.4,
                height: 150,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: color1,
                ),
                child: const Text('Resumen 1'),
              ),
              Container(
                width: screenWidth * 0.4,
                height: 150,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: color2,
                ),
                child: const Text('Resumen 2'),
              ),
              Container(
                width: screenWidth * 0.4,
                height: 150,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: color3,
                ),
                child: const Text('Resumen 3'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
