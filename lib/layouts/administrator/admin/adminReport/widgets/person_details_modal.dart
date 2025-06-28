import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';

class PersonDetailsModal extends StatelessWidget {
  final Map<String, dynamic> persona;
  final VoidCallback onClose;
  final bool isDarkMode;

  const PersonDetailsModal({
    super.key,
    required this.persona,
    required this.onClose,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black45,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {},
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles de ${persona['nombre']} ${persona['apellido']}',
                      style: TextStyles.boldPrimaryText(context)
                          .copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow('Nombre', persona['nombre'], theme),
                    _buildDetailRow('Apellido', persona['apellido'], theme),
                    _buildDetailRow('Cédula', persona['cedula'], theme),
                    _buildDetailRow('Estado', persona['estado'], theme),
                    _buildDetailRow('Habilitado',
                        (persona['habilitado'] == true) ? 'Sí' : 'No', theme),
                    _buildDetailRow('Membresía',
                        persona['membresia'] ?? 'No aplica', theme),
                    _buildDetailRow(
                        'Tipo', persona['tipo'] ?? 'No aplica', theme),
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
            flex: 4,
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
