import 'package:flutter/material.dart';

class GeneroSelector extends StatefulWidget {
  const GeneroSelector({super.key});

  @override
  _GeneroSelectorState createState() => _GeneroSelectorState();
}

class _GeneroSelectorState extends State<GeneroSelector> {
  String? _generoSeleccionado = 'Masculino';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona el género',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Opción Masculino
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _generoSeleccionado == 'Masculino'
                      ? Colors.blue.shade400
                      : Colors.grey.shade300,
                  foregroundColor: _generoSeleccionado == 'Masculino'
                      ? Colors.white
                      : Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _generoSeleccionado = 'Masculino';
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 4.5,
                      backgroundColor: _generoSeleccionado == 'Masculino'
                          ? Colors.white
                          : Colors.black,
                    ),
                    const SizedBox(width: 10),
                    const Text('Masculino', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 30),
            // Opción Femenino
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _generoSeleccionado == 'Femenino'
                      ? Colors.pink.shade300
                      : Colors.grey.shade300,
                  foregroundColor: _generoSeleccionado == 'Femenino'
                      ? Colors.white
                      : Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _generoSeleccionado = 'Femenino';
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 4.5,
                      backgroundColor: _generoSeleccionado == 'Femenino'
                          ? Colors.white
                          : Colors.black,
                    ),
                    const SizedBox(width: 10),
                    const Text('Femenino', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
