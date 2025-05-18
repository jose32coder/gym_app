import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Membership extends StatefulWidget {
  final bool pagoInmediato;
  const Membership({super.key, required this.pagoInmediato});

  @override
  State<Membership> createState() => _MembershipState();
}

class _MembershipState extends State<Membership> {
  final _formKey = GlobalKey<FormState>();

  String _membership = '';  // Inicializado en string vacío

  final TextEditingController _dateInitController = TextEditingController();
  final TextEditingController _dateFinalController = TextEditingController();
  final TextEditingController _amountBsController = TextEditingController();
  final TextEditingController _amountUsdController = TextEditingController();
  final TextEditingController _paymentRefController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void dispose() {
    _dateInitController.dispose();
    _dateFinalController.dispose();
    _amountBsController.dispose();
    _amountUsdController.dispose();
    _paymentRefController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Campo obligatorio';
    if (double.tryParse(value.replaceAll(',', '.')) == null)
      return 'Debe ser un monto válido';
    return null;
  }

  String? _validateDateRange() {
    if (_dateInitController.text.isEmpty)
      return 'Selecciona la fecha de inicio';
    if (_dateFinalController.text.isEmpty) return 'Selecciona la fecha final';

    DateTime start = _dateFormat.parse(_dateInitController.text);
    DateTime end = _dateFormat.parse(_dateFinalController.text);

    if (end.isBefore(start))
      return 'Fecha final no puede ser anterior a la inicial';
    return null;
  }

  void _setDateRange(String tipo) {
    DateTime now = DateTime.now();
    DateTime end;

    switch (tipo) {
      case 'Diario':
        end = now;
        break;
      case 'Semanal':
        end = now.add(const Duration(days: 7));
        break;
      case 'Mensual':
        end = DateTime(now.year, now.month + 1, now.day);
        break;
      default:
        end = now;
    }

    setState(() {
      _dateInitController.text = _dateFormat.format(now);
      _dateFinalController.text = _dateFormat.format(end);
    });
  }

  void _resetForm() {
    setState(() {
      _membership = '';
      _dateInitController.clear();
      _dateFinalController.clear();
      _amountBsController.clear();
      _amountUsdController.clear();
      _paymentRefController.clear();

      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.zero,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Membresía',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Tipo', style: TextStyles.boldText(context)),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: _membership.isEmpty ? null : _membership,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.card_membership),
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                filled: true,
              ),
              items: [
                const DropdownMenuItem(
                    value: '', child: Text('Selecciona el tipo de membresía')),
                ...['Diario', 'Semanal', 'Mensual']
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _membership = value ?? '';
                });
                if (_membership.isNotEmpty) _setDateRange(_membership);
                _formKey.currentState?.validate();
              },
              validator: (value) {
                if (_membership.isEmpty) {
                  return 'Selecciona una membresía válida';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text('Fechas', style: TextStyles.boldText(context)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateInitController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha Inicio',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Campo obligatorio'
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _dateFinalController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha Fin',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Campo obligatorio'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Pago', style: TextStyles.boldText(context)),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountBsController,
                    decoration: InputDecoration(
                      hintText: 'Monto en Bs',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Text('Bs', style: TextStyle(fontSize: 18)),
                      fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                      filled: true,
                      helperText: ' ', // <- reserva espacio aunque no haya error
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: _validateAmount,
                    onChanged: (_) {
                      if (_formKey.currentState!.validate()) {
                        setState(() {}); // fuerza rebuild para actualizar errores
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _amountUsdController,
                    decoration: InputDecoration(
                      hintText: 'Monto en \$',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.attach_money),
                      fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                      filled: true,
                      helperText: ' ', // <- igual aquí
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: _validateAmount,
                    onChanged: (_) {
                      if (_formKey.currentState!.validate()) {
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _paymentRefController,
              decoration: InputDecoration(
                hintText: 'Referencia de pago móvil',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.payment),
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                filled: true,
                helperText: ' ',
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Campo obligatorio' : null,
              onChanged: (_) {
                if (_formKey.currentState!.validate()) {
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pago registrado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
      
                  _resetForm();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Por favor, completa correctamente todos los campos'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Registrar Pago',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
