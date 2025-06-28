import 'package:basic_flutter/components/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback onTap;

  const PaymentCard({
    required this.payment,
    required this.onTap,
    super.key,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = getPaymentIcon(theme.colorScheme.primary);

    final nombre = (payment['nombre'] is String)
        ? payment['nombre'] as String
        : 'Sin nombre';

    final fechaTimestamp = payment['fechaPago'];
    DateTime? fecha;
    if (fechaTimestamp is DateTime) {
      fecha = fechaTimestamp;
    } else if (fechaTimestamp is Timestamp) {
      fecha = fechaTimestamp.toDate();
    } else {
      fecha = null;
    }

    final nombreMembresia = (payment['nombreMembresia'] is String)
        ? payment['nombreMembresia'] as String
        : 'Sin membresía';

    final monto = (payment['monto'] is num) ? payment['monto'] as num : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: icon,
          title: Text(
            nombre,
            style: TextStyles.boldPrimaryText(context),
          ),
          subtitle: fecha != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Fecha de pago: ${_formatDate(fecha)}',
                      style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 12),
                    ),
                    Text(
                      'Membresía: ${(nombreMembresia)}',
                      style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 12),
                    ),
                  ],
                )
              : null,
          trailing: Text(
            '\$${monto.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

Icon getPaymentIcon(Color color) {
  return Icon(Icons.payment, color: color);
}
