import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/admin/adminPay/widgets/components/membership_payment_currency.dart';
import 'package:basic_flutter/models/model_membership.dart';
import 'package:basic_flutter/viewmodel/membership_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/membership_amount_field.dart';
import 'components/membership_date_fields.dart';

class Membership extends StatefulWidget {
  const Membership({super.key});

  @override
  State<Membership> createState() => _MembershipState();
}

class _MembershipState extends State<Membership> {
  final _formKey = GlobalKey<FormState>();

  // Estado
  List<MembershipModel> _membresiasActivas = [];
  bool isLoadingMembresias = true;
  bool hayPromocion = false;

  String _membership = '';
  String _promos = '';

  // bool _entrenadorPersonal = false;

  final TextEditingController _dateRangeController = TextEditingController();
  String _paymentCurrency = 'Dólares';

  final TextEditingController _amountUsdController = TextEditingController();
  final TextEditingController _amountBsController = TextEditingController();
  final TextEditingController _amountTotalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarMembresias();
  }

  Future<void> _cargarMembresias() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final membresiasVM =
        Provider.of<MembershipViewmodel>(context, listen: false);
    final membresias =
        await membresiasVM.obtenerMembresiasActivasPorUsuario(uid);

    setState(() {
      _membresiasActivas = membresias;
      isLoadingMembresias = false;
    });
  }

  void _updateAmounts() {
    // Puedes implementar lógica para actualizar montos según condiciones
    print('Actualizando montos...');
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Membresías',
              style: TextStyles.boldPrimaryText(context),
            ),
            const SizedBox(height: 5),
            // Dropdown de tipos de membresías activas
            DropdownButtonFormField<String>(
              value: _membership.isNotEmpty ? _membership : null,
              items: _membresiasActivas.map((membresia) {
                return DropdownMenuItem(
                  value: membresia.name,
                  child: Text(
                      '${membresia.name} — \$${membresia.price?.toStringAsFixed(2) ?? 'N/A'}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _membership = value ?? '';
                });
              },
              decoration: InputDecoration(
                hintText: 'Tipo de Membresía',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              validator: (value) => _membership.isEmpty
                  ? 'Selecciona una membresía válida'
                  : null,
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Text(
                  '¿Hay promoción?',
                  style: TextStyles.boldPrimaryText(context),
                ),
                SizedBox(
                  width: 12,
                ),
                Switch(
                  value: hayPromocion,
                  onChanged: (value) {
                    setState(() {
                      hayPromocion = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            if (hayPromocion) ...[
              Text(
                'Promociones',
                style: TextStyles.boldPrimaryText(context),
              ),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: _membership.isNotEmpty ? _membership : null,
                items: _membresiasActivas.map((membresia) {
                  return DropdownMenuItem(
                    value: membresia.name,
                    child: Text(
                        '${membresia.name} — \$${membresia.price?.toStringAsFixed(2) ?? 'N/A'}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _membership = value ?? '';
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Tipo de Membresía',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) => _membership.isEmpty
                    ? 'Selecciona una membresía válida'
                    : null,
              ),
              SizedBox(
                height: 16,
              ),

              // PersonalTrainerCheckbox — opcional, descomentable si deseas
              // PersonalTrainerCheckbox(
              //   entrenadorPersonal: _entrenadorPersonal,
              //   onChanged: (value) {
              //     setState(() {
              //       _entrenadorPersonal = value ?? false;
              //       _updateAmounts();
              //     });
              //   },
              // ),

              // const SizedBox(height: 16),
              Text(
                'Descuento',
                style: TextStyles.boldPrimaryText(context),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: _amountTotalController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Monto con descuento',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                  fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                  filled: true,
                  helperText: ' ',
                ),
              ),
            ],

            // Fecha de membresía
            MembershipDateFields(
              dateRangeController: _dateRangeController,
            ),
            const SizedBox(height: 16),

            Text(
              'Tipo de pago',
              style: TextStyles.boldPrimaryText(context),
            ),
            SizedBox(
              height: 5,
            ),
            // Selector de moneda
            PaymentCurrencySelector(
              paymentCurrency: _paymentCurrency,
              onChanged: (value) {
                setState(() {
                  _paymentCurrency = value ?? 'Dólares';
                  _updateAmounts();
                });
              },
            ),
            const SizedBox(height: 16),

            // Campos de monto
            MembershipAmountFields(
              paymentCurrency: _paymentCurrency,
              amountUsdController: _amountUsdController,
              amountBsController: _amountBsController,
              validateAmount: _validateAmount,
            ),

            const SizedBox(height: 10),

            // Botón de registrar pago
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Aquí puedes gestionar el submit del pago
                    print('Pago registrado');
                  }
                },
                icon: Icon(Icons.login, color: theme.colorScheme.onSurface),
                label: Text(
                  'Registrar pago',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
