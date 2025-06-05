import 'package:flutter/material.dart';

class MembershipDateFields extends StatelessWidget {
  final TextEditingController dateInitController;
  final TextEditingController dateFinalController;

  const MembershipDateFields({
    super.key,
    required this.dateInitController,
    required this.dateFinalController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: dateInitController,
            decoration: const InputDecoration(
              labelText: 'Fecha Inicio',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            validator: (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: dateFinalController,
            decoration: const InputDecoration(
              labelText: 'Fecha Fin',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            validator: (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
          ),
        ),
      ],
    );
  }
}
