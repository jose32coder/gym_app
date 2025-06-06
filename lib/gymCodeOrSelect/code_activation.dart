import 'package:basic_flutter/components/button.dart';
import 'package:basic_flutter/viewmodel/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CodeActivation extends StatefulWidget {
  const CodeActivation({super.key});

  @override
  State<CodeActivation> createState() => _CodeActivationState();
}

class _CodeActivationState extends State<CodeActivation> {
  final _codigoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();

  bool _cargando = false;

  // Simulación de que el código es válido para mostrar el formulario
  bool codigoValido = false; // Cambia a false para ocultar el formulario

  void _validarYCrearGimnasio() async {
    if (!_formKey.currentState!.validate()) return;

    final usuarioVM = Provider.of<UserViewmodel>(context, listen: false);
    final codigo = _codigoController.text.trim();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingresa un código de activación')),
      );
      return;
    }

    setState(() {
      _cargando = true;
    });

    final esValido = await usuarioVM.validarCodigoActivacion(codigo, uid);

    if (!esValido) {
      setState(() {
        _cargando = false;
        codigoValido = false; // Para ocultar formulario si no es válido
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código inválido o ya utilizado ❌')),
      );
      return;
    }
    setState(() {
      _cargando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gimnasio creado correctamente ✅')),
    );

    Navigator.pop(context); // o navegar a dashboard
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration({
    required String hintText,
    required Icon prefixIcon,
    required bool isDarkMode,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      prefixIcon: prefixIcon,
      fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
      filled: true,
      suffixIcon: suffixIcon,
    );
  }

  void _activar() async {
    final usuarioVM = Provider.of<UserViewmodel>(context, listen: false);
    final codigo = _codigoController.text.trim();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes iniciar sesión para activar el código')),
      );
      return;
    }
    final uid = currentUser.uid;

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingresa un código de activación')),
      );
      return;
    }

    setState(() {
      _cargando = true;
    });

    final esValido = await usuarioVM.validarCodigoActivacion(codigo, uid);

    setState(() {
      _cargando = false;
      codigoValido = esValido;
    });

    if (!esValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código inválido o ya utilizado ❌')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activar gimnasio'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
                controller: _codigoController,
                decoration: buildInputDecoration(
                  hintText: 'Codigo de activación',
                  prefixIcon: const Icon(
                    Icons.lock,
                    size: 24,
                  ),
                  isDarkMode: isDarkMode,
                )),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _activar,
                icon: Icon(
                  Icons.key,
                  color: isDarkMode
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onInverseSurface,
                ),
                label: Text(
                  'Activar',
                  style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onInverseSurface),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Si el código es válido mostramos el formulario
            if (codigoValido)
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Datos del gimnasio',
                      style: theme.textTheme.headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nombreController,
                      decoration: buildInputDecoration(
                        hintText: 'Nombre del gimnasio',
                        prefixIcon: const Icon(
                          Icons.fitness_center,
                          size: 24,
                        ),
                        isDarkMode: isDarkMode,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Dirección',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.location_on_sharp),
                        fillColor:
                            isDarkMode ? Colors.grey.shade800 : Colors.white,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Telefono',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                        fillColor:
                            isDarkMode ? Colors.grey.shade800 : Colors.white,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: GuardarDatosButton(
                        uid: uid ?? '',
                        codigo: _codigoController.text.trim(),
                        tipoUsuario: 'Dueño',
                        nombreGimnasio: _nombreController.text.trim(),
                        direccionGimnasio: _direccionController.text.trim(),
                        telefonoGimnasio: _telefonoController.text.trim(),
                        buttonText: 'Guardar Gimnasio',
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
