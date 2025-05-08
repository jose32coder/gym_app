import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';

class PlanMembership extends StatelessWidget {
  const PlanMembership({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Definir colores según tema
    final membershipColors = [
      isDarkMode ? Colors.blue[700] : Colors.blue[100],
      isDarkMode ? Colors.green[700] : Colors.green[100],
      isDarkMode ? Colors.red[700] : Colors.red[100],
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Planes de Membresía',
          style: TextStyles.boldText(context),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(3, (index) {
              return Container(
                width: screenWidth * 0.9,
                height: 150,
                padding: const EdgeInsets.all(20),
                margin: EdgeInsets.only(
                  left: index == 0 ? 0 : 10,
                  top: 10,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: isDarkMode ? Colors.white24 : Colors.black26,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: membershipColors[index],
                ),
                child: Text(
                  'Membresía ${index + 1}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
