import 'package:basic_flutter/viewmodel/auth_viewmodel.dart';
import 'package:basic_flutter/viewmodel/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GuardarDatosButton extends StatelessWidget {
  final String uid;
  final String codigo;
  final String tipoUsuario;
  final String buttonText;

  final String? nombreGimnasio;
  final String? direccionGimnasio;
  final String? telefonoGimnasio;

  const GuardarDatosButton({
    super.key,
    required this.uid,
    required this.codigo,
    required this.tipoUsuario,
    this.nombreGimnasio,
    this.direccionGimnasio,
    this.telefonoGimnasio,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewmodel>(context);

    return ElevatedButton(
      onPressed: viewModel.isLoading
          ? null
          : () async {
              await viewModel.manejarGuardarYActualizar(
                uid: uid,
                codigo: codigo,
                tipoUsuario: tipoUsuario,
                nombreGimnasio: nombreGimnasio,
                direccionGimnasio: direccionGimnasio,
                telefonoGimnasio: telefonoGimnasio,
              );

              if (viewModel.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(viewModel.successMessage!)),
                );
              } else if (viewModel.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(viewModel.errorMessage!)),
                );
              }
            },
      child: viewModel.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(buttonText),
    );
  }
}
