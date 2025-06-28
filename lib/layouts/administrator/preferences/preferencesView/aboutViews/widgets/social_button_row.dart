import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialButtonsRow extends StatelessWidget {
  const SocialButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.facebook, color: theme.colorScheme.primary),
          onPressed: () {
            // Abrir Facebook
          },
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.xTwitter, color: theme.colorScheme.primary),
          onPressed: () {
            // Abrir Twitter/X
          },
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.instagram, color: theme.colorScheme.primary),
          onPressed: () {
            // Abrir Instagram
          },
        ),
      ],
    );
  }
}
