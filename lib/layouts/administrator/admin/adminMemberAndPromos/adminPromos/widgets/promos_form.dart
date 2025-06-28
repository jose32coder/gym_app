// ignore_for_file: use_build_context_synchronously

import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/models/model_promo.dart';
import 'package:basic_flutter/viewmodel/promos_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PromosForm extends StatefulWidget {
  final PromotionModel? promotionEdit;
  const PromosForm({super.key, this.promotionEdit});

  @override
  State<PromosForm> createState() => _PromosFormState();
}

class _PromosFormState extends State<PromosForm> {
  final TextEditingController promotionNameController = TextEditingController();
  double discountValue = 0;

  final TextEditingController discount2Controller = TextEditingController();
  final TextEditingController discount3Controller = TextEditingController();
  final TextEditingController discount4Controller = TextEditingController();

  bool showGroupDiscounts = false;

  void resetForm() {
    promotionNameController.clear();
    discountValue = 0;
    discount2Controller.clear();
    discount3Controller.clear();
    discount4Controller.clear();
    showGroupDiscounts = false;
    setState(() {});
  }

  @override
  void dispose() {
    promotionNameController.dispose();
    discount2Controller.dispose();
    discount3Controller.dispose();
    discount4Controller.dispose();
    super.dispose();
  }

  void _guardarPromotion() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final nombre = promotionNameController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('El nombre de la promoción es obligatorio')),
      );
      return;
    }

    final Map<int, double> groupDiscounts = {};
    if (discount2Controller.text.isNotEmpty) {
      groupDiscounts[2] = double.tryParse(discount2Controller.text) ?? 0;
    }
    if (discount3Controller.text.isNotEmpty) {
      groupDiscounts[3] = double.tryParse(discount3Controller.text) ?? 0;
    }
    if (discount4Controller.text.isNotEmpty) {
      groupDiscounts[4] = double.tryParse(discount4Controller.text) ?? 0;
    }

    final nuevaPromo = PromotionModel(
      name: nombre,
      discount: discountValue,
      groupDiscount: groupDiscounts,
    );

    try {
      await PromotionViewModel().guardarPromocion(
        usuarioId: uid,
        promotion: nuevaPromo,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promoción guardada correctamente')),
      );

      resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar promoción: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Promoción'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.bell),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const NotificationModal(),
                );
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: promotionNameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la Promoción',
                prefixIcon: const Icon(Icons.card_giftcard),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Slider de descuento
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Descuento (%)',
                  style: theme.textTheme.titleMedium,
                ),
                Slider(
                  value: discountValue,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  activeColor: theme.colorScheme.primary,
                  label: '${discountValue.toStringAsFixed(0)}%',
                  onChanged: (value) {
                    setState(() {
                      discountValue = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sección descuentos por grupo
            ListTile(
              title: Text(
                'Descuentos por grupo',
                style: theme.textTheme.titleMedium,
              ),
              trailing: Icon(
                showGroupDiscounts
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
              onTap: () {
                setState(() {
                  showGroupDiscounts = !showGroupDiscounts;
                });
              },
            ),

            if (showGroupDiscounts)
              Column(
                children: [
                  const SizedBox(height: 10),
                  _buildGroupDiscountField(
                      'Para 2 personas (%)', discount2Controller),
                  const SizedBox(height: 10),
                  _buildGroupDiscountField(
                      'Para 3 personas (%)', discount3Controller),
                  const SizedBox(height: 10),
                  _buildGroupDiscountField(
                      'Para 4 personas (%)', discount4Controller),
                ],
              ),

            const SizedBox(height: 30),

            // Botones
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _guardarPromotion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      Icons.add,
                      color: isDarkMode
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onInverseSurface,
                    ),
                    label: Text(
                      'Guardar',
                      style: TextStyle(
                        color: isDarkMode
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: resetForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
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
                      'Cancelar',
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
          ],
        ),
      ),
    );
  }

  Widget _buildGroupDiscountField(
      String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: false),
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: const Icon(Icons.group),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
