import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(
          icon,
          color: isDarkMode
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onInverseSurface,
        ),
        label: Text(
          text,
          style: TextStyle(
            color: isDarkMode
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onInverseSurface,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
