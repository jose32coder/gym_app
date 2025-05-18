import 'package:flutter/material.dart';

class FilterDrop extends StatelessWidget {
  final String? estadoSeleccionado;
  final Function(String?) onChanged;

  const FilterDrop({
    super.key,
    required this.estadoSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: estadoSeleccionado,
      hint: const Text('Filtrar por estado'),
      items: const [
        DropdownMenuItem(value: 'vencido', child: Text('Vencido')),
        DropdownMenuItem(value: 'por vencer', child: Text('Por vencer')),
        DropdownMenuItem(value: 'activo', child: Text('Activo')),
      ],
      onChanged: onChanged,
    );
  }
}
