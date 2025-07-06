import 'package:flutter/material.dart';

class SearchingBar extends StatelessWidget {
  final TextEditingController controller;
  final ThemeData theme;

  const SearchingBar(
      {super.key, required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // <-- Aquí lo agregas
      decoration: InputDecoration(
        hintText: 'Buscar...',
        hintStyle: TextStyle(color: theme.hintColor),
        prefixIcon: Icon(
          Icons.search,
          color: theme.colorScheme.primary,
        ),
        filled: true,
        fillColor: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : Colors.grey.shade100,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.9),
            width: 0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        hoverColor: theme.colorScheme.primary.withOpacity(0.1),
      ),
    );
  }
}
