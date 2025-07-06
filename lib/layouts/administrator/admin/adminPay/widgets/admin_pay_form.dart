import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/components/validations.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/pay_register.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/widgets/comprobanteCard.dart';
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
import 'package:collection/collection.dart';

class AdminPayForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController cedulaController;
  final TextEditingController nombreController;
  final TextEditingController? amountUsdController;
  final TextEditingController? amountBsController;
  final TextEditingController? paymentReferenceController;
  final String? Function()? onValidateCedula;

  const AdminPayForm(
      {super.key,
      required this.formKey,
      required this.cedulaController,
      required this.nombreController,
      this.amountBsController,
      this.amountUsdController,
      this.paymentReferenceController,
      this.onValidateCedula});

  @override
  State<AdminPayForm> createState() => _AdminPayFormState();
}

class _AdminPayFormState extends State<AdminPayForm> {
  // Estado
  final GlobalKey<PayAmountFieldState> _payAmountFieldKey =
      GlobalKey<PayAmountFieldState>();
  final GlobalKey<PayRegisterState> _payRegisterKey =
      GlobalKey<PayRegisterState>();
  List<MembershipModel> _membresiasActivas = [];
  List<PromotionModel> _promociones = [];
  bool isLoadingMembresias = true;
  bool isLoadingPromociones = true;
  bool hayPromocion = false;
  bool isLoading = false;

  String _membership = '';
  String _selectedPromocion = '';
  final uid = FirebaseAuth.instance.currentUser!.uid;
  MembershipModel? membresiaSeleccionada;

  late FocusNode _cedFocusNode;
  late FocusNode _memberFocusNode;
  late FocusNode _montoBsFocusNode;

  String? _memberError;
  String? _cedError;
  String? _montoBsError;
  bool _payAmountHasError = false;
  DateTime? _fechaCorte;

  final TextEditingController _dateRangeController = TextEditingController();
  String _paymentCurrency = 'Dólares';
  double? montoDolar;

  final TextEditingController _paymentReferenceController =
      TextEditingController();
  final TextEditingController _amountUsdController = TextEditingController();
  final TextEditingController _amountBsController = TextEditingController();
  final TextEditingController _amountTotalController = TextEditingController();
  final TextEditingController _referenceAmountBsController =
      TextEditingController();
  final TextEditingController _observationsController = TextEditingController();

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
    _cedFocusNode.dispose();
    _memberFocusNode.dispose();
    _montoBsFocusNode.dispose();
    _dateRangeController.dispose();
    _amountUsdController.dispose();
    _amountBsController.dispose();
    _referenceAmountBsController.dispose();
    _amountTotalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cargarMembresias();
    _cargarPromociones();

    _cedFocusNode = FocusNode();
    _memberFocusNode = FocusNode();
    _montoBsFocusNode = FocusNode();

    _cedFocusNode.addListener(() {
      if (!_cedFocusNode.hasFocus) {
        setState(() {
          _cedError = Validations.validateCed(widget.cedulaController.text);
        });
      }
    });

    _memberFocusNode.addListener(() {
      if (!_memberFocusNode.hasFocus) {
        setState(() {
          _memberError = Validations.validateMembershipName(_membership);
        });
      }
    });

    _montoBsFocusNode.addListener(() {
      if (!_montoBsFocusNode.hasFocus) {
        setState(() {
          _montoBsError =
              Validations.validateAmountBsAndDollar(_amountBsController.text);
        });
      }
    });
  }

  void _cargarMembresias() {
    final membresiasVM =
        Provider.of<MembershipViewmodel>(context, listen: false);

    membresiasVM.obtenerMembresiasPorUsuario(uid).listen((membresias) {
      setState(() {
        _membresiasActivas = membresias;
        isLoadingMembresias = false;
        if (_membership.isNotEmpty) {
          _actualizarRangoFecha(_membership);
        }
      });
    });
  }

  void _actualizarRangoFecha(String membershipName) {
    final int? dias = membershipDurations[membershipName];
    if (dias != null) {
      final DateTime ahora = DateTime.now();
      final DateTime fechaFin = ahora.add(Duration(days: dias));

      // Guardamos fechaFin en _fechaCorte
      _fechaCorte = fechaFin;

      _dateRangeController.text =
          '${ahora.day}/${ahora.month}/${ahora.year} - ${fechaFin.day}/${fechaFin.month}/${fechaFin.year}';
    } else {
      _fechaCorte = null;
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
    final cedulaError = widget.onValidateCedula?.call();
    final isFormValid = widget.formKey.currentState?.validate() ?? false;

    setState(() {
      _cedError = Validations.validateCed(widget.cedulaController.text);
      _memberError = Validations.validateMembershipName(_membership);
    });

    if (!isFormValid || cedulaError != null || _payAmountHasError) {
      if (cedulaError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cedulaError)),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    final payVM = Provider.of<PayViewModel>(context, listen: false);

    if (_membership.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una membresía')),
      );
      return;
    }

    double? monto = double.tryParse(_amountTotalController.text);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monto inválido')),
      );
      return;
    }

    if (_paymentCurrency == 'Dólares') {
      montoDolar = monto;
    } else {
      montoDolar = double.tryParse(_amountUsdController.text.trim()) ?? 0.0;
    }

    await payVM.registrarPago(
      cedula: widget.cedulaController.text.trim(),
      nombre: widget.nombreController.text.trim(),
      nombreMembresia: membresiaSeleccionada?.name ?? '',
      membresiaId: membresiaSeleccionada?.id ?? '',
      monto: monto,
      fechaPago: DateTime.now(),
      fechaCorte: _fechaCorte,
      montoBs: double.tryParse(_amountBsController.text.trim()) ?? 0.0,
      reference: _referenceAmountBsController.text.trim(),
      montoDollar: montoDolar,
      observation: _observationsController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pago registrado correctamente')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComprobanteCard(
          nombre: widget.nombreController.text,
          cedula: widget.cedulaController.text,
          concepto:
              'Comprobante de pago realizado por la persona ${widget.nombreController.text}',
          membresia: membresiaSeleccionada?.name ?? 'Sin membresía',
          tipoPago: _paymentCurrency ??
              'Sin definir', // <-- este valor deberías tenerlo en tu formulario
          montoDolares:
              montoDolar, // <-- debe existir como double? en tu widget
          montoBolivares:
              double.tryParse(_amountBsController.text.trim()), // idem
          montoTotal: monto, // <-- monto total calculado
          fecha: DateTime.now().toString(),
        ),
      ),
    );

    widget.formKey.currentState!.reset();
    widget.cedulaController.clear();
    widget.nombreController.clear();
    _amountTotalController.clear();

    setState(() {
      membresiaSeleccionada =
          null; // Asumiendo que quieres limpiar la selección
    });
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
              style: TextStyles.boldText(context),
            ),
            const SizedBox(height: 5),
            // Dropdown de tipos de membresías activas
            DropdownButtonFormField<String>(
              focusNode: _memberFocusNode,
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

                  // Aquí buscas el modelo completo según el nombre seleccionado
                  membresiaSeleccionada = _membresiasActivas.firstWhereOrNull(
                    (m) => m.name == value,
                  );

                  _cedError = Validations.validateCed(value);
                  _actualizarRangoFecha(_membership);
                  _calcularMontoTotal();
                });
              },
              decoration: InputDecoration(
                hintText: 'Tipo de Membresía',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validations.validateMembershipName,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Tiempo de membresía',
              style: TextStyles.boldText(context),
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
                  style: TextStyles.boldText(context),
                ),
                const SizedBox(
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
            const SizedBox(
              height: 16,
            ),
            if (hayPromocion) ...[
              Text(
                'Promociones',
                style: TextStyles.boldText(context),
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
              const SizedBox(
                height: 16,
              ),
            ],
            Text(
              'Monto total',
              style: TextStyles.boldText(context),
            ),
            const SizedBox(
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
              style: TextStyles.boldText(context),
            ),
            const SizedBox(
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
            const SizedBox(
              height: 10,
            ),

            // Campos de monto
            PayAmountField(
              key: _payAmountFieldKey,
              paymentReferenceController: _paymentReferenceController,
              paymentCurrency: _paymentCurrency,
              amountUsdController: _amountUsdController,
              amountBsController: _amountBsController,
              referenceAmountController: _referenceAmountBsController,
              onValidationChanged: (hasError) {
                setState(() {
                  _payAmountHasError = hasError;
                });
              },
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              'Observaciones',
              style: TextStyles.boldText(context),
            ),
            const SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: _observationsController,
              maxLines: 5, // Puedes ajustar esto según la altura que necesites
              minLines: 1,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.notes),
                hintText: 'Observaciones',
                alignLabelWithHint:
                    true, // Para que la etiqueta quede alineada arriba
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                filled: true,
              ),
            ),

            const SizedBox(height: 20),

            // Botón de registrar pago
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _newpay,
                icon: Icon(
                  Icons.login,
                  color: isDarkMode
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onInverseSurface,
                ),
                label: Text(
                  'Registrar pago',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onInverseSurface,
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
