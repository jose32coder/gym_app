import 'package:flutter/material.dart';

class FilterDate extends StatelessWidget {
  final DateTime? fechaSeleccionada;
  final Function(DateTime?) onDateSelected;

  const FilterDate({
    super.key,
    required this.fechaSeleccionada,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final DateTime? fecha = await showDatePicker(
          context: context,
          initialDate: fechaSeleccionada ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (fecha != null) {
          onDateSelected(fecha);
        }
      },
      child: Text(fechaSeleccionada == null
          ? 'Seleccionar fecha'
          : 'Fecha: ${fechaSeleccionada!.toLocal().toIso8601String().substring(0, 10)}'),
    );
  }
}
