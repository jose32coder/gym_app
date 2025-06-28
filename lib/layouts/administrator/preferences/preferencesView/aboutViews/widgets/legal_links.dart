import 'package:flutter/material.dart';

class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            // Navegar a términos y condiciones
          },
          child: const Text('Términos y Condiciones'),
        ),
        TextButton(
          onPressed: () {
            // Navegar a política de privacidad
          },
          child: const Text('Política de Privacidad'),
        ),
      ],
    );
  }
}
