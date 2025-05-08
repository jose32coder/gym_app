import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/components/genero_selector.dart';
import 'package:flutter/material.dart';

class TextFormPage extends StatefulWidget {
  const TextFormPage({super.key});
  @override
  State<TextFormPage> createState() => _TextFormPageState();
}

class _TextFormPageState extends State<TextFormPage> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String? _generoSeleccionado = 'Masculino';
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nombre',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Introduce el nombre',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Persona registrada correctamente'),
                  ),
                );
              } else {
                // Si existe algún campo inválido
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Hay campos vacíos o con algún error',
                      style: TextStyle(fontSize: 16),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor:Colors.blue.shade400,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text(
              'Registrar',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
