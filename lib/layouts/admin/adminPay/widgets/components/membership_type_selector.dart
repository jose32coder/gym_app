import 'package:flutter/material.dart';

class MembershipTypeSelector extends StatelessWidget {
  final String membership;
  final List<String> membershipTypes;
  final Function(String?) onChanged;
  final FormFieldValidator<String>? validator;

  const MembershipTypeSelector({
    super.key,
    required this.membership,
    required this.membershipTypes,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      value: membership.isEmpty ? null : membership,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.card_membership),
        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
        filled: true,
      ),
      items: [
        const DropdownMenuItem(
          value: '',
          child: Text('Selecciona el tipo de membresía'),
        ),
        ...membershipTypes.map(
          (item) => DropdownMenuItem(value: item, child: Text(item)),
        ),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}
