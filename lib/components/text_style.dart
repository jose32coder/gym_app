import 'package:flutter/material.dart';

class TextStyles {
  static TextStyle boldText(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.white : Colors.black87,
    );
  }
}
