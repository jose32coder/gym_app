import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';

class Membership extends StatefulWidget {
  final GlobalKey<FormState> formKey;  // Recibimos el GlobalKey desde el componente principal

  const Membership({super.key, required this.formKey});

  @override
  State<Membership> createState() => _MembershipState();
}

class _MembershipState extends State<Membership> {
  String? _membership = 'Diario';
  final TextEditingController _dateInitController = TextEditingController();
  final TextEditingController _dateFinalController = TextEditingController();

  // Función para seleccionar la fecha
  Future<void> _selectDate(TextEditingController controller,
      {DateTime? initialDate, DateTime? firstDate, DateTime? lastDate}) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        controller.text =
            "${selectedDate.toLocal()}".split(' ')[0]; // Formato yyyy-mm-dd
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: widget.formKey,  // Usamos el formKey pasado desde el componente principal
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Membresía',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20,),
          Text(
              'Tipo',
              style: TextStyles.boldText(context)
            ),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: _membership,
            decoration: InputDecoration(
              hintText: 'Selecciona un género',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.person),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
            ),
            items: ['Diario', 'Semanal', 'Mensual']
                .map((genero) => DropdownMenuItem<String>(
                      value: genero,
                      child: Text(genero),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _membership = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Debes seleccionar una membresía';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _dateInitController,
                  decoration: const InputDecoration(
                    hintText: 'Fecha Inicio',
                    labelText: 'Fecha Inicio',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    await _selectDate(_dateInitController);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _dateFinalController,
                  decoration: const InputDecoration(
                    hintText: 'Fecha Fin',
                    labelText: 'Fecha Fin',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? initialDate = _dateInitController.text.isNotEmpty
                        ? DateTime.parse(_dateInitController.text)
                        : DateTime.now();
                    await _selectDate(_dateFinalController,
                        initialDate: initialDate, firstDate: initialDate);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Pago',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Monto en Bs',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      child: Text('Bs', style: TextStyle(fontSize: 18)),
                    ),
                    fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Debe ser un monto válido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Monto en \$',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                    fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Debe ser un monto válido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Introduce la referencia del pago móvil',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.payment),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
