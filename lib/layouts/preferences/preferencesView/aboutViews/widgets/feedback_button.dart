import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          'Desarrollado por el equipo FitnestX © 2025',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            // Abrir formulario de feedback o enviar correo
          },
          icon: const FaIcon(FontAwesomeIcons.solidCommentDots),
          label: const Text('Enviar Feedback'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
