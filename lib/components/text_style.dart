import 'package:flutter/material.dart';

class TextStyles {
  static TextStyle boldText(BuildContext context) {
    final theme = Theme.of(context);

    return TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface);
  }

  static TextStyle boldPrimaryText(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: isDarkMode
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onInverseSurface,
    );
  }
}
