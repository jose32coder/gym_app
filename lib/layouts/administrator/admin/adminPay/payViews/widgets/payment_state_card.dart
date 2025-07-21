import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';

class PaymentStateCard extends StatelessWidget {
  final Map<String, dynamic> cliente;
  final String estado;

  const PaymentStateCard({
    super.key,
    required this.cliente,
    required this.estado,
  });

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'pendiente':
        return Colors.amber;
      case 'vencido':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = _getEstadoColor(estado);

    final cedula = cliente['cedula'] ?? 'Sin cédula';
    final nombre = cliente['nombre'] ?? 'Nombre';
    final apellido = cliente['apellido'] ?? 'Apellido';
    final estatus = cliente['estado'] ?? 'Estado';

    IconData iconoEstado;
    Color colorIcono;

    switch (estatus.toLowerCase()) {
      case 'activo':
        iconoEstado = Icons.check;
        colorIcono = Colors.green;
        break;
      case 'pendiente':
        iconoEstado = Icons.warning;
        colorIcono = Colors.orange;
        break;
      case 'atrasado':
        iconoEstado = Icons.close;
        colorIcono = Colors.red;
        break;
      default:
        iconoEstado = Icons.help_outline;
        colorIcono = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          radius: 8,
          backgroundColor: colorEstado,
        ),
        title: Text(
          '$nombre $apellido',
          style: TextStyles.boldText(context),
        ),
        subtitle: Text('Cédula: $cedula'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              estatus,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: colorIcono, fontSize: 12),
            ),
            const SizedBox(width: 6),
            Icon(
              iconoEstado,
              color: colorIcono,
            ),
          ],
        ),
      ),
    );
  }
}
