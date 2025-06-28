import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/widgets/components/pay_currency.dart';
import 'package:basic_flutter/models/model_membership.dart';
import 'package:basic_flutter/models/model_promo.dart';
import 'package:basic_flutter/viewmodel/membership_viewmodel.dart';
import 'package:basic_flutter/viewmodel/pay_viewmodel.dart';
import 'package:basic_flutter/viewmodel/promos_viewmodel.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/pay_amount_field.dart';
import 'components/pay_date_fields.dart';

class AdminPayForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController cedulaController;
  final TextEditingController nombreController;
  final TextEditingController? amountUsdController;
  final TextEditingController? amountBsController;

  const AdminPayForm(
      {super.key,
      required this.formKey,
      required this.cedulaController,
      required this.nombreController,
      this.amountBsController,
      this.amountUsdController});

  @override
  State<AdminPayForm> createState() => _AdminPayFormState();
}

class _AdminPayFormState extends State<AdminPayForm> {
  // Estado
  List<MembershipModel> _membresiasActivas = [];
  List<PromotionModel> _promociones = [];
  bool isLoadingMembresias = true;
  bool isLoadingPromociones = true;
  bool hayPromocion = false;

  String _membership = '';
  String _selectedPromocion = '';
  final uid = FirebaseAuth.instance.currentUser!.uid;
  MembershipModel? membresiaSeleccionada;

  // bool _entrenadorPersonal = false;

  final TextEditingController _dateRangeController = TextEditingController();
  String _paymentCurrency = 'Dólares';

  final TextEditingController _amountUsdController = TextEditingController();
  final TextEditingController _amountBsController = TextEditingController();
  final TextEditingController _amountTotalController = TextEditingController();

  Map<String, int> membershipDurations = {
    'Diario': 1,
    'Semanal': 7,
    'Quincenal': 15,
    'Mensual': 30,
    'Trimestral': 90,
    'Semestral': 180,
    'Anual': 365,
  };

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cargarMembresias();
    _cargarPromociones();
  }

  Future<void> _cargarMembresias() async {
    final membresiasVM =
        Provider.of<MembershipViewmodel>(context, listen: false);
    final membresias =
        await membresiasVM.obtenerMembresiasActivasPorUsuario(uid);

    setState(() {
      _membresiasActivas = membresias;
      isLoadingMembresias = false;
      if (_membership.isNotEmpty) {
        _actualizarRangoFecha(_membership);
      }
    });
  }

  void _actualizarRangoFecha(String membershipName) {
    final int? dias = membershipDurations[membershipName];
    if (dias != null) {
      final DateTime ahora = DateTime.now();
      final DateTime fechaFin = ahora.add(Duration(days: dias));

      _dateRangeController.text =
          '${ahora.day}/${ahora.month}/${ahora.year} - ${fechaFin.day}/${fechaFin.month}/${fechaFin.year}';
    } else {
      _dateRangeController.clear();
    }
  }

  Future<void> _cargarPromociones() async {
    final promocionesVM =
        Provider.of<PromotionViewModel>(context, listen: false);
    final promociones =
        await promocionesVM.obtenerPromocionesPorUsuario(uid).first;

    setState(() {
      _promociones = promociones;
      isLoadingPromociones = false;
    });
  }

  void _calcularMontoTotal() {
    membresiaSeleccionada = _membresiasActivas.firstWhereOrNull(
      (membresia) => membresia.name == _membership,
    );

    if (membresiaSeleccionada == null) {
      _amountTotalController.text = '';
      return;
    }

    double precioBase = membresiaSeleccionada!.price ?? 0.0;
    double descuento = 0.0;

    if (hayPromocion && _selectedPromocion.isNotEmpty) {
      final promocionSeleccionada = _promociones.firstWhereOrNull(
        (promo) => promo.name == _selectedPromocion,
      );

      if (promocionSeleccionada != null) {
        descuento = promocionSeleccionada.discount;
      }
    }

    double montoFinal = precioBase - (precioBase * (descuento / 100));

    _amountTotalController.text = montoFinal.toStringAsFixed(2);
  }

  void _newpay() async {
    if (widget.formKey.currentState!.validate()) {
      final payVM = Provider.of<PayViewModel>(context, listen: false);

      if (_membership.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debe seleccionar una membresía')),
        );
        return;
      }

      double? monto = double.tryParse(_amountTotalController.text);
      if (monto == null || monto <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Monto inválido')),
        );
        return;
      }

      await payVM.registrarPago(
        cedula: widget.cedulaController.text.trim(),
        nombre: widget.nombreController.text.trim(),
        nombreMembresia: membresiaSeleccionada?.name ?? '',
        monto: double.tryParse(_amountTotalController.text.trim()) ?? 0.0,
        fechaPago: DateTime.now(),
        montoBs: double.tryParse(_amountBsController.text.trim()) ?? 0.0,
        montoDollar: double.tryParse(_amountUsdController.text.trim()) ??
            double.tryParse(_amountTotalController.text.trim()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pago registrado correctamente')),
      );

      widget.formKey.currentState!.reset();
      widget.cedulaController.clear();
      widget.nombreController.clear();
      _amountTotalController.clear();
      setState(() {
        membresiaSeleccionada?.name ?? '';
      });
    }
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
        key: widget.formKey,
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
                  _actualizarRangoFecha(_membership);
                  _calcularMontoTotal();
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
            const SizedBox(
              height: 10,
            ),
            Text(
              'Tiempo de membresía',
              style: TextStyles.boldPrimaryText(context),
            ),
            const SizedBox(
              height: 5,
            ),
            // Fecha de membresía
            PayDateFields(
              dateRangeController: _dateRangeController,
            ),
            const SizedBox(height: 16),

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
                      _calcularMontoTotal();
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
                value:
                    _selectedPromocion.isNotEmpty ? _selectedPromocion : null,
                items: _promociones.map((promo) {
                  return DropdownMenuItem(
                    value: promo.name,
                    child: Text(
                      '${promo.name}/${promo.discount.toStringAsFixed(0)}% descuento',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPromocion = value ?? '';
                    _calcularMontoTotal();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Tipo de promoción',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) => _selectedPromocion.isEmpty
                    ? 'Selecciona una promoción válida'
                    : null,
              ),
              SizedBox(
                height: 16,
              ),
            ],
            Text(
              'Monto total',
              style: TextStyles.boldPrimaryText(context),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: _amountTotalController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Monto total',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.attach_money),
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                filled: true,
                helperText: ' ',
              ),
            ),

            Text(
              'Tipo de pago',
              style: TextStyles.boldPrimaryText(context),
            ),
            SizedBox(
              height: 5,
            ),
            // Selector de moneda
            PayCurrency(
              paymentCurrency: _paymentCurrency,
              onChanged: (value) {
                setState(() {
                  _paymentCurrency = value ?? 'Dólares';
                });
              },
            ),
            const SizedBox(height: 16),

            // Campos de monto
            PayAmountField(
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
                onPressed: _newpay,
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
