import 'package:flutter/material.dart';

class ComprobanteCard extends StatelessWidget {
  final String nombre;
  final String cedula;
  final String concepto;
  final String membresia;
  final double montoTotal;
  final String tipoPago;
  final double? montoDolares;
  final double? montoBolivares;
  final String fecha;

  const ComprobanteCard({
    Key? key,
    required this.nombre,
    required this.cedula,
    required this.concepto,
    required this.membresia,
    required this.montoTotal,
    required this.tipoPago,
    this.montoDolares,
    this.montoBolivares,
    required this.fecha,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '📄 Comprobante de Pago',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 30, thickness: 1),
            TextLabelValue(label: 'Nombre:', value: nombre),
            TextLabelValue(label: 'Cédula:', value: cedula),
            TextLabelValue(label: 'Membresía:', value: membresia),
            TextLabelValue(label: 'Concepto:', value: concepto),
            TextLabelValue(label: 'Tipo de Pago:', value: tipoPago),
            const SizedBox(height: 8),
            if (tipoPago == 'Ambos' || tipoPago == 'Dólares')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monto en \$:',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  Text(
                    '\$ ${montoDolares?.toStringAsFixed(2) ?? '0.00'}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            if (tipoPago == 'Ambos' || tipoPago == 'Bolívares')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monto en Bs:',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  Text(
                    '${montoBolivares?.toStringAsFixed(2) ?? '0,00'} Bs',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            const SizedBox(height: 4),
            Text(
              'Monto Total:',
              style:
                  theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            Text(
              '\$ ${montoTotal.toStringAsFixed(2)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Fecha:',
              style:
                  theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            Text(
              fecha,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class TextLabelValue extends StatelessWidget {
  final String label;
  final String value;

  const TextLabelValue({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label ',
              style:
                  theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
