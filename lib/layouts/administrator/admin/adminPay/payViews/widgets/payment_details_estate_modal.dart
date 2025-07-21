import 'package:flutter/material.dart';

class ClienteDetailsModal extends StatelessWidget {
  final Map<String, dynamic> cliente;
  final VoidCallback? onClose;

  const ClienteDetailsModal({
    super.key,
    required this.cliente,
    required this.onClose,
  });

  String _formatDate(dynamic date) {
    if (date == null) return 'Fecha no disponible';

    DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is Map && date['_seconds'] != null) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000);
    } else {
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
    final nombre = cliente['nombre'] ?? 'Sin nombre';
    final apellido = cliente['apellido'] ?? '';
    final cedula = cliente['cedula'] ?? 'Sin cédula';
    final estado = cliente['estado'] ?? 'Estado no definido';
    final fechaCorte = cliente['fechaCorte'];
    final fechaUltimoPago = cliente['fechaUltimoPago'];
    final telefono = cliente['telefono'] ?? 'No disponible';
    final correo = cliente['correo'] ?? 'No disponible';

    final theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onClose,
      child: Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {}, // Evita que el modal se cierre al tocar dentro
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
                    'Estado del cliente',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('Nombre', '$nombre $apellido'),
                  _buildDetailRow('Cédula', cedula),
                  _buildDetailRow('Estado', estado),
                  _buildDetailRow('Fecha de corte', _formatDate(fechaCorte)),
                  _buildDetailRow('Último pago', _formatDate(fechaUltimoPago)),
                  _buildDetailRow('Teléfono', telefono),
                  _buildDetailRow('Correo', correo),
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
