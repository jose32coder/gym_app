import 'package:flutter/material.dart';
import 'package:basic_flutter/models/model_membership.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MembershipDetails extends StatefulWidget {
  final MembershipModel membership;
  final String gimnasioId;
  final String membershipDocId; // ID único del documento membresía

  const MembershipDetails({
    super.key,
    required this.membership,
    required this.gimnasioId,
    required this.membershipDocId,
  });

  @override
  _MembershipDetailsState createState() => _MembershipDetailsState();
}

class _MembershipDetailsState extends State<MembershipDetails> {
  late bool isActive;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isActive = widget.membership.isActive;
  }

  Future<void> toggleIsActive() async {
    setState(() {
      isLoading = true;
    });

    try {
      final docRef = FirebaseFirestore.instance
          .collection('gimnasios')
          .doc(widget.gimnasioId)
          .collection('membresias')
          .doc(widget.membershipDocId);

      await docRef.update({'isActive': !isActive});

      setState(() {
        isActive = !isActive;
      });
    } catch (e) {
      // Manejo de error más sofisticado recomendado (Snackbar, diálogo, etc)
      print('Error al actualizar estado: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de la Membresía',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Nombre', widget.membership.name, theme),
            _buildDetailRow('Tipo', widget.membership.membershipType, theme),
            _buildDetailRow(
                'Precio',
                '\$${(widget.membership.price ?? 0.0).toStringAsFixed(2)}',
                theme),
            _buildDetailRow('Activo', isActive ? 'Sí' : 'No', theme),
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
