import 'package:flutter/material.dart';

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    String fecha =
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.blue.shade700 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '👋 Bienvenido, Alberto',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hoy es $fecha',
            style: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: isDarkMode ? Colors.grey[300] : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
