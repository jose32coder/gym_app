import 'package:flutter/material.dart';

class AppLogoSection extends StatelessWidget {
  const AppLogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 100,
          child: Image.asset('assets/images/avatar.png'),
        ),
        const SizedBox(height: 12),
        Text(
          'FitnestX',
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Versión 1.0.0',
          style: theme.textTheme.bodyMedium,
        ),
        const Divider(height: 40),
        Text(
          'FitnestX es una aplicación diseñada para ayudarte a mejorar tu salud y forma física, '
          'ofreciendo rutinas personalizadas, seguimiento de progreso y consejos profesionales.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const Divider(height: 40),
      ],
    );
  }
}
