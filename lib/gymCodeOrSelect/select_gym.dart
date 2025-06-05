import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectGym extends StatelessWidget {
  const SelectGym({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona un gimnasio'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('gimnasios').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay gimnasios registrados aún.'),
            );
          }

          final gimnasios = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: gimnasios.length,
            itemBuilder: (context, index) {
              final gimnasio = gimnasios[index];
              final nombre = gimnasio['nombre'] ?? 'Sin nombre';
              final direccion = gimnasio['direccion'] ?? 'Sin dirección';

              return ListTile(
                tileColor: theme.colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.fitness_center),
                title: Text(nombre, style: const TextStyle(fontSize: 18)),
                subtitle: Text(direccion),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Aquí puedes guardar el gimnasio seleccionado en tu ViewModel o prefs
                  // Y llevar al cliente a su home
                  // Por ahora solo navegación de ejemplo:
                  Navigator.pushReplacementNamed(context, '/homeCliente');
                },
              );
            },
          );
        },
      ),
    );
  }
}
