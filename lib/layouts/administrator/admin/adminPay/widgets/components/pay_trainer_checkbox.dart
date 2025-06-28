import 'package:flutter/material.dart';

class PayTrainerCheckbox extends StatelessWidget {
  final bool entrenadorPersonal;
  final ValueChanged<bool?> onChanged;

  const PayTrainerCheckbox({
    super.key,
    required this.entrenadorPersonal,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: entrenadorPersonal,
          onChanged: onChanged,
        ),
        const Text('Entrenador personal (+ costo extra)'),
      ],
    );
  }
}
