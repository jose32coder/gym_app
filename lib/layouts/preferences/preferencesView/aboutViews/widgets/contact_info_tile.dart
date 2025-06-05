import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactInfoTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final String onTapDescription;

  const ContactInfoTile({
    super.key,
    required this.icon,
    required this.text,
    required this.onTapDescription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: FaIcon(icon, color: theme.colorScheme.primary),
      title: Text(text),
      onTap: () {
    
      },
    );
  }
}
