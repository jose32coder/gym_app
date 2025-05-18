import 'package:flutter/material.dart';

class SearchingBar extends StatelessWidget {
  final TextEditingController controller;
  final ThemeData theme;

  const SearchingBar(
      {super.key, required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Buscar por nombre',
            prefixIcon:
                Icon(Icons.search, color: Theme.of(context).primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
        ));
  }
}
