import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/persons/widgets/genero_selector.dart';
import 'package:basic_flutter/layouts/admin/adminPay/payViews/pay_register.dart';
import 'package:flutter/material.dart';

class TextFormPage extends StatefulWidget {
  const TextFormPage({
    super.key,
  });

  @override
  State<TextFormPage> createState() => _TextFormPageState();
}

class _TextFormPageState extends State<TextFormPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cédula',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Introduce la cédula',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.badge),
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
          Text(
            'Nombre',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Introduce el nombre',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.account_circle),
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
          const SizedBox(height: 15),
          Text(
            'Apellido',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Introduce el apellido',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.account_circle),
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
          const GeneroSelector(),
          const SizedBox(height: 20),
          Text(
            'Dirección',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Introduce la dirección...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.location_on_sharp),
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
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Llamar al diálogo modal para preguntar si quiere pagar ahora
                final bool? pagarAhora = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('¿Deseas pagar la membresía ahora?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Solo registrar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Pagar ahora'),
                      ),
                    ],
                  ),
                );

                if (pagarAhora != null) {
                  if (pagarAhora) {
                    // Navegar a Membership con pagoInmediato = true
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PayRegister(
                          desdeAdmin: false,
                          cedula: '12345678',
                          nombreCompleto: 'Jose Perez',
                        ),
                      ),
                    );
                  } else {
                    // Solo registro sin pago
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Membresía registrada sin pago')),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Completa todos los campos correctamente'),
                    backgroundColor: Colors.red,
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
              'Registrar',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
