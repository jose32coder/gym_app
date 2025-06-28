import 'package:basic_flutter/models/model_promo.dart';
import 'package:flutter/material.dart';

class PromotionDetails extends StatelessWidget {
  final PromotionModel promotion;
  final String gimnasioId;
  final String promotionDocId;

  const PromotionDetails({
    super.key,
    required this.promotion,
    required this.gimnasioId,
    required this.promotionDocId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalles de la Promoción',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Nombre', promotion.name, theme),
              _buildDetailRow('Descuento general',
                  '${promotion.discount.toStringAsFixed(0)}%', theme),
              const SizedBox(height: 16),
              if (promotion.groupDiscount.isNotEmpty) ...[
                Text(
                  'Descuentos por grupo:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...promotion.groupDiscount.entries.map((entry) =>
                    _buildDetailRow('Grupo ${entry.key}',
                        '${entry.value.toStringAsFixed(0)}%', theme)),
              ] else
                Text(
                  'No hay descuentos grupales.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
