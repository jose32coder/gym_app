import 'package:flutter/material.dart';
import 'package:basic_flutter/data/movimientos_data.dart';

class ListaMovimientos extends StatelessWidget {
  final int cantidadAMostrar;

  const ListaMovimientos({super.key, required this.cantidadAMostrar});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> movimientosFiltrados =
        movimientos.take(cantidadAMostrar).toList();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: movimientosFiltrados.length,
      itemBuilder: (context, index) {
        final movimiento = movimientosFiltrados[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              width: 2,
              color: isDarkMode ? Colors.white : Colors.black87
            )),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: const Icon(Icons.attach_money, color: Colors.blue),
            title: Text(movimiento['titulo']!),
            subtitle: Text(movimiento['fecha']!),
            trailing: Text(
              movimiento['monto']!,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
