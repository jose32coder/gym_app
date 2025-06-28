import 'package:flutter/material.dart';

class PaymentDetailsModal extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback onClose;

  const PaymentDetailsModal({
    super.key,
    required this.payment,
    required this.onClose,
  });

  Icon _getPaymentIcon(String? tipoPago, Color color) {
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

  String _formatDate(dynamic date) {
    if (date == null) return 'Fecha no disponible';

    DateTime dateTime;
    // Aquí debes ajustar según si usas Timestamp u otro tipo
    if (date is DateTime) {
      dateTime = date;
    } else if (date is Map && date['_seconds'] != null) {
      // Firebase Timestamp (si acaso)
      dateTime = DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000);
    } else {
      // Si no es DateTime ni Timestamp válido
      return 'Fecha inválida';
    }

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
    return "${dateTime.day.toString().padLeft(2, '0')} ${months[dateTime.month - 1]} ${dateTime.year}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final nombre = (payment['nombre'] as String?)?.isNotEmpty == true
        ? payment['nombre']
        : 'Sin nombre';

    final monto = (payment['monto'] is num) ? payment['monto'] as num : 0.0;

    final fechaPago = payment['fechaPago'];

    final tipoPago = (payment['tipoPago'] as String?)?.isNotEmpty == true
        ? payment['tipoPago']
        : 'No especificado';

    final montoBolivares =
        (payment['montoBs'] is num) ? payment['montoBs'] as num : 0.0;

    final montoDolares =
        (payment['montoDollar'] is num) ? payment['montoDollar'] as num : 0.0;

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black45,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {}, // evitar cerrar al tocar dentro
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Detalles del pago',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('Nombre', nombre),
                  _buildDetailRow('Monto', '\$${monto.toStringAsFixed(2)}'),
                  _buildDetailRow('Fecha de pago', _formatDate(fechaPago)),
                  _buildDetailRow(
                      'Bolivares', montoBolivares.toStringAsFixed(2)),
                  _buildDetailRow(
                      'Dolares (\$)', montoDolares.toStringAsFixed(2)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de Pago: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      _getPaymentIcon(tipoPago, theme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tipoPago,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onInverseSurface,
                      ),
                      label: Text(
                        'Cerrar',
                        style: TextStyle(
                          color: isDarkMode
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onInverseSurface,
                        ),
                      ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
