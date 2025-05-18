import 'package:flutter/material.dart';

class MemberCardState extends StatelessWidget {
  final String cliente;
  final String fechaVencimiento;
  final String estado;
  final double monto;

  const MemberCardState({
    super.key,
    required this.cliente,
    required this.fechaVencimiento,
    required this.estado,
    required this.monto,
  });

  @override
  Widget build(BuildContext context) {
    Color colorIcono = estado == 'Vencido'
        ? Colors.red
        : estado == 'Por Vencer'
            ? Colors.orange
            : Colors.green;

    IconData icono = estado == 'Vencido'
        ? Icons.warning_amber
        : estado == 'Por Pencer'
            ? Icons.access_time
            : Icons.check_circle;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icono, color: colorIcono),
        title: Text(cliente),
        subtitle: Text('Vence: $fechaVencimiento | Estado: $estado'),
        trailing: Text(
          '\$${monto.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorIcono,
          ),
        ),
      ),
    );
  }
}
