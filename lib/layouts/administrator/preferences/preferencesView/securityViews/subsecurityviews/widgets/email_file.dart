import 'package:flutter/material.dart';

class EmailFile extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onToggle;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final String? errorText;
  final bool? readOnly;

  const EmailFile({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onToggle,
    this.focusNode,
    this.validator,
    this.autovalidateMode,
    this.errorText,
    this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      readOnly: false,
      controller: controller,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode,
      validator: validator,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.email),
        filled: true,
        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        errorText: errorText,
      ),
    );
  }
}
