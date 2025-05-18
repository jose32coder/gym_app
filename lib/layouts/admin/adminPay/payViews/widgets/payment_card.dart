import 'package:basic_flutter/layouts/admin/adminPay/payViews/widgets/payment_icons.dart';
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
    final icon = getPaymentIcon(payment['tipoPago'], theme.colorScheme.primary);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: icon,
        title: Text(
          payment['nombre'],
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        subtitle: Text(
          _formatDate(payment['fecha']),
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        trailing: Text(
          '\$${payment['monto'].toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary, // Para que destaque
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
