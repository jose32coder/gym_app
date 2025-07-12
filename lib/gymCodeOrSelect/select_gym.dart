import 'package:basic_flutter/components/qr_viewscreen.dart';
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
  String codigo = '';

  final TextEditingController _codeController = TextEditingController();
  bool isLoading = false;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _onRegisterGym(
      String gimnasioId, String gymName, String code) async {
    setState(() => isLoading = true);

    try {
      final userVM = Provider.of<UserViewmodel>(context, listen: false);
      final authVM = Provider.of<AuthViewmodel>(context, listen: false);

      final userData = await authVM.obtenerDatosUsuario(uid);
      final gymData = await userVM.obtenerDatosGym(uid);

      if (userData != null) {
        nombreUsuario = userData['nombre'] ?? '';
        apellidoUsuario = userData['apellido'] ?? '';
      }

      if (gymData != null) {
        codigo = gymData['codigo'] ?? '';
      }

      final isCodigoValido = await userVM.validarCodigoActivacion(code, uid);
      if (!isCodigoValido) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código inválido o ya usado')),
        );
        return;
      }

      await userVM.registrarUsuarioEnGimnasio(
        usuarioId: uid,
        tipoUsuario: widget.rol,
        gimnasioId: gimnasioId,
        codigoActivacion: _codeController.text.trim(),
      );

      await userVM.marcarCodigoComoUsado(code, uid);

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

    Navigator.pop(context); // cerrar vista actual si aplica
  }

  void _showCodeDialog(BuildContext context, String gimnasioId, String nombre) {
    String? errorText;
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // 👈 permite setState dentro del dialog
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Código de Registro'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Agrega el código de invitación del gimnasio para poder registrarte',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      hintText: 'Código',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.lock_rounded),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        onPressed: () async {
                          final code = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QrViewscreen(),
                            ),
                          );

                          if (code != null) {
                            _codeController.text = code;
                            // Validación inmediata:
                            final userVM = Provider.of<UserViewmodel>(context,
                                listen: false);
                            final isCodigoValido =
                                await userVM.validarCodigoActivacion(code, uid);

                            if (!isCodigoValido) {
                              setState(() {
                                errorText = 'Código inválido o ya utilizado';
                              });
                              return;
                            }

                            Navigator.of(context).pop();
                            _onRegisterGym(gimnasioId, nombre, code);
                          }
                        },
                      ),
                      fillColor:
                          isDarkMode ? Colors.grey.shade800 : Colors.white,
                      filled: true,
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 45),
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDarkMode
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onInverseSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final code = _codeController.text.trim();
                          if (code.isEmpty) {
                            setState(() {
                              errorText = 'Debes ingresar un código';
                            });
                            return;
                          }

                          final userVM = Provider.of<UserViewmodel>(context,
                              listen: false);
                          final isCodigoValido =
                              await userVM.validarCodigoActivacion(code, uid);

                          if (!isCodigoValido) {
                            setState(() {
                              errorText = 'Código inválido o ya utilizado';
                            });
                            return;
                          }

                          // Si es válido, cerrar diálogo y registrar
                          Navigator.of(context).pop();
                          _onRegisterGym(gimnasioId, nombre, code);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 45),
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Aceptar',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDarkMode
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onInverseSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
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
                                _showCodeDialog(context, gimnasio.id, nombre),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 45),
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Registrarse',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onInverseSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
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
