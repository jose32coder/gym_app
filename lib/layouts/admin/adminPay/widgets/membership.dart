import 'package:basic_flutter/layouts/admin/adminPay/widgets/components/membership_payment_currency.dart';
import 'package:basic_flutter/layouts/admin/adminPay/widgets/components/membership_trainer_checkbox.dart';
import 'package:flutter/material.dart';
import 'components/membership_amount_field.dart';
import 'components/membership_type_selector.dart';
import 'components/membership_date_fields.dart';

class Membership extends StatefulWidget {
  const Membership({super.key});

  @override
  State<Membership> createState() => _MembershipState();
}

class _MembershipState extends State<Membership> {
  final _formKey = GlobalKey<FormState>();

  // Estados
  String _membership = '';
  final List<String> _membershipTypes = [
    'Diario',
    'Semanal',
    'Quincenal',
    'Mensual',
    'Trimestral',
    'Anual'
  ];

  bool _entrenadorPersonal = false;

  final TextEditingController _dateInitController = TextEditingController();
  final TextEditingController _dateFinalController = TextEditingController();

  String _paymentCurrency = 'Ambos';

  final TextEditingController _amountUsdController = TextEditingController();
  final TextEditingController _amountBsController = TextEditingController();

  // Funciones
  void _setDateRange(String membership) {
    // Ejemplo simple de rangos
    DateTime now = DateTime.now();
    DateTime end;

    switch (membership) {
      case 'Diario':
        end = now.add(const Duration(days: 1));
        break;
      case 'Semanal':
        end = now.add(const Duration(days: 7));
        break;
      case 'Quincenal':
        end = now.add(const Duration(days: 15));
        break;
      case 'Mensual':
        end = DateTime(now.year, now.month + 1, now.day);
        break;
      case 'Trimestral':
        end = DateTime(now.year, now.month + 3, now.day);
        break;
      case 'Anual':
        end = DateTime(now.year + 1, now.month, now.day);
        break;
      default:
        end = now;
    }
    _dateInitController.text = '${now.day}/${now.month}/${now.year}';
    _dateFinalController.text = '${end.day}/${end.month}/${end.year}';
  }

  void _updateAmounts() {
    // Aquí puedes ajustar lógica para modificar montos según condiciones
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
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MembershipTypeSelector(
              membership: _membership,
              membershipTypes: _membershipTypes,
              onChanged: (value) {
                setState(() {
                  _membership = value ?? '';
                  _setDateRange(_membership);
                  _updateAmounts();
                });
              },
              validator: (value) => _membership.isEmpty
                  ? 'Selecciona una membresía válida'
                  : null,
            ),
            const SizedBox(height: 16),
            PersonalTrainerCheckbox(
              entrenadorPersonal: _entrenadorPersonal,
              onChanged: (value) {
                setState(() {
                  _entrenadorPersonal = value ?? false;
                  _updateAmounts();
                });
              },
            ),
            const SizedBox(height: 16),
            MembershipDateFields(
              dateInitController: _dateInitController,
              dateFinalController: _dateFinalController,
            ),
            const SizedBox(height: 16),
            PaymentCurrencySelector(
              paymentCurrency: _paymentCurrency,
              onChanged: (value) {
                setState(() {
                  _paymentCurrency = value ?? 'Ambos';
                  _updateAmounts();
                });
              },
            ),
            const SizedBox(height: 16),
            MembershipAmountFields(
              paymentCurrency: _paymentCurrency,
              amountUsdController: _amountUsdController,
              amountBsController: _amountBsController,
              validateAmount: _validateAmount,
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: (){},
                icon: Icon(Icons.login, color: theme.colorScheme.onSurface),
                label: Text(
                  'Registrar pago',
                  style: TextStyle(
                      fontSize: 16, color: theme.colorScheme.onSurface),
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
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
