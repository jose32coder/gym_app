import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/widgets/comprobanteCard.dart';
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
      case 'Bolívares':
        return Icon(Icons.monetization_on, color: color);
      case 'Dólares':
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
    final cedula = (payment['cedula'] as String?)?.isNotEmpty == true
        ? payment['cedula']
        : 'Sin cédula';
    final referencia = (payment['referencia'] != null &&
            payment['referencia'].toString().isNotEmpty)
        ? payment['referencia'].toString()
        : 'Sin referencia';
    final nombreMembresia =
        (payment['nombreMembresia'] as String?)?.isNotEmpty == true
            ? payment['nombreMembresia']
            : 'Sin nombre';
    final monto = (payment['monto'] is num) ? payment['monto'] as num : 0.0;

    final tipoPago = payment['tipoPago'];

    final fechaPago = payment['fechaPago'];

    final montoBolivares =
        (payment['montoBs'] is num) ? payment['montoBs'] as num : 0.0;

    final montoDolares =
        (payment['montoDollares'] is num)
        ? payment['montoDollares'] as num
        : 0.0;

    return GestureDetector(
      onTap: onClose,
      child: Container(
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
                  _buildDetailRow('Cédula', cedula),
                  _buildDetailRow('Nombre', nombre),
                  _buildDetailRow('Monto', '\$${monto.toStringAsFixed(2)}'),
                  _buildDetailRow(
                      'Dólares (\$)', montoDolares.toStringAsFixed(2)),
                  _buildDetailRow(
                      'Bolivares (Bs)', montoBolivares.toStringAsFixed(2)),
                  _buildDetailRow('Referencia', referencia),
                  _buildDetailRow('Fecha de pago', _formatDate(fechaPago)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        onClose(); // Cierra el modal actual primero
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ComprobanteCard(
                              nombre: nombre,
                              cedula: cedula,
                              concepto:
                                  'Comprobante de pago realizado por $nombre',
                              membresia: nombreMembresia ?? 'Sin membresía',
                              montoDolares: montoDolares.toDouble(),
                              montoBolivares: montoBolivares.toDouble(),
                              montoTotal: monto.toDouble(),
                              tipoPago: tipoPago.toString(),
                              fecha: fechaPago.toString(),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        Icons.print,
                        color: isDarkMode
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onInverseSurface,
                      ),
                      label: Text(
                        'Comprobante',
                        style: TextStyle(
                          color: isDarkMode
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
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
