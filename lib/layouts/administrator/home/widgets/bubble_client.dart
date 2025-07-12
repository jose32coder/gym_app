import 'package:flutter/material.dart';

class BubbleClient extends StatelessWidget {
  final Map<String, dynamic> cliente;
  final VoidCallback onTap;

  const BubbleClient({required this.cliente, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final nombre = cliente['nombre'] ?? 'Sin nombre';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              child: Text(inicial),
            ),
            const SizedBox(width: 10),
            Text(
              nombre,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
