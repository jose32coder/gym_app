import 'package:basic_flutter/viewmodel/user_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CodesAdminPage extends StatefulWidget {
  const CodesAdminPage({super.key});

  @override
  State<CodesAdminPage> createState() => _CodesAdminPageState();
}

class _CodesAdminPageState extends State<CodesAdminPage> {
  Future<void> _generarCodigo() async {
    final userViewmodel = Provider.of<UserViewmodel>(context, listen: false);

    final codigoGenerado = await userViewmodel.crearCodigo();

    _mostrarCodigoDialog(codigoGenerado);
  }

  void _mostrarCodigoDialog(String codigo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Código generado'),
        content: Text(
          codigo,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrador de Códigos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Generar un nuevo código de activación único:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _generarCodigo,
                icon: const Icon(Icons.vpn_key),
                label: const Text(
                  'Generar código',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
