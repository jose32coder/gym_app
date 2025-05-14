import 'package:basic_flutter/components/membership.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/components/genero_selector.dart';
import 'package:flutter/material.dart';

class TextFormPage extends StatefulWidget {
  final bool showMembresia;

  const TextFormPage({
    super.key,
    this.showMembresia = false,
  });

  @override
  State<TextFormPage> createState() => _TextFormPageState();
}

class _TextFormPageState extends State<TextFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _membershipKey = GlobalKey<FormState>(); // Añadido para la membresía

  @override
  Widget build(BuildContext context) {
    final bool mostrarMembresia;
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
          if (widget.showMembresia) Membership(formKey: _membershipKey),
          
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (_membershipKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Persona registrada correctamente')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hay campos vacíos o con algún error',
                            style: TextStyle(fontSize: 16)),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              }
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue.shade400,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text(
              'Registrar',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(height: 10,)
        ],
      ),
    );
  }
}
