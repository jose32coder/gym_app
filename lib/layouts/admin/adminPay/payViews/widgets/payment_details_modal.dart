import 'package:flutter/material.dart';

class PaymentDetailsModal extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback onClose;

  const PaymentDetailsModal({
    required this.payment,
    required this.onClose,
  });

  Icon _getPaymentIcon(String tipoPago, Color color) {
    switch (tipoPago) {
      case 'Bolívares (Bs)':
        return Icon(Icons.monetization_on, color: color);
      case 'Dólares (\$)':
        return Icon(Icons.attach_money, color: color);
      case 'Ambos':
        return Icon(Icons.account_balance_wallet, color: color);
      default:
        return Icon(Icons.payment, color: color);
    }
  }

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
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {}, // evitar cerrar al tocar dentro
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 32),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Detalles del Pago',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),

                  _buildDetailRow('Nombre', payment['nombre']),
                  _buildDetailRow('Monto', '\$${payment['monto'].toStringAsFixed(2)}'),
                  _buildDetailRow('Fecha', _formatDate(payment['fecha'])),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo de Pago: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      _getPaymentIcon(payment['tipoPago'], theme.primaryColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          payment['tipoPago'],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow(
                    'Referencia',
                    payment['referencia'] ?? 'Sin referencia',
                  ),
                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: onClose,
                    child: Text('Cerrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
