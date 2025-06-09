import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/viewmodel/auth_viewmodel.dart';
import 'package:basic_flutter/viewmodel/user_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class SelectGym extends StatefulWidget {
  final String rol;
  const SelectGym({super.key, required this.rol});

  @override
  State<SelectGym> createState() => _SelectGymState();
}

class _SelectGymState extends State<SelectGym> {
  String nombreUsuario = '';
  String apellidoUsuario = '';
  bool isLoading = false;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _onRegisterGym(String gimnasioId, String gymName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: Text('¿Estás seguro(a) que deseas unirte a "$gymName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isLoading = true);

    try {
      final userVM = Provider.of<UserViewmodel>(context, listen: false);
      final authVM = Provider.of<AuthViewmodel>(context, listen: false);

      final userData = await authVM.obtenerDatosUsuario(uid);

      if (userData != null) {
        nombreUsuario = userData['nombre'] ?? '';
        apellidoUsuario = userData['apellido'] ?? '';
      }

      // Aquí ya no llamas obtenerCodigoGimnasio porque tienes el gimnasioId
      await userVM.registrarUsuarioEnGimnasio(
        uid: uid,
        tipoUsuario: widget.rol,
        gimnasioId: gimnasioId,
        nombre: nombreUsuario,
        apellido: apellidoUsuario,
        talla: null,
        peso: null,
        membresia: null,
        pago: null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Te has unido al gimnasio "$gymName"')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seleccionar Gimnasio',
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('gimnasios').snapshots(),
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
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: gimnasios.length,
                itemBuilder: (context, index) {
                  final gimnasio = gimnasios[index];
                  final nombre = gimnasio['nombre'] ?? 'Sin nombre';
                  final direccion = gimnasio['direccion'] ?? 'Sin dirección';
                  final telefono = gimnasio['telefono'] ?? 'Sin teléfono';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: theme.colorScheme.surfaceVariant,
                    child: ExpansionTile(
                      title: Text(
                        nombre,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      leading: const Icon(Icons.fitness_center),
                      childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(direccion)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.phone,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(telefono)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _onRegisterGym(gimnasio.id, nombre),
                            child: Text(
                              'Registrarse',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onInverseSurface),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 45),
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // Overlay con indicador de carga
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
