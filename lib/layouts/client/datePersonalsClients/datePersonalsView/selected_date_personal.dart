import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/client/widgets/edad_selector.dart';
import 'package:flutter/material.dart';

class SelectedDatePersonal extends StatefulWidget {
  const SelectedDatePersonal({super.key});

  @override
  State<SelectedDatePersonal> createState() => _SelectedDatePersonalState();
}

class _SelectedDatePersonalState extends State<SelectedDatePersonal> {
  int _edadSeleccionada = 20;

  void valorEdad() {
    print(_edadSeleccionada);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cuentame sobre tí',
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: SafeArea(
          child: Column(
            children: [
              const Text(
                'Seleccionada tu edad:',
                style: TextStyle(fontSize: 26),
              ),
              const SizedBox(height: 5),
              const Center(
                child: Text(
                  '¿Por qué tu edad? Esto ayuda a mejorar tu experiencia en la app',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              EdadSelector(
                minEdad: 14,
                maxEdad: 70,
                edadInicial: _edadSeleccionada,
                onEdadChanged: (edad) {
                  setState(() {
                    _edadSeleccionada = edad;
                  });
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        // Acción botón Devolverme
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Devolverme',
                        style: TextStyle(
                          color: isDarkMode
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        valorEdad();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Continuar',
                        style: TextStyle(
                          color: isDarkMode
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
