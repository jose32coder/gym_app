import 'package:basic_flutter/layouts/admin/adminPay/widgets/membership.dart';
import 'package:flutter/material.dart';

class PayRegister extends StatefulWidget {
  final bool desdeAdmin;
  final String? cedula;
  final String? nombreCompleto;

  const PayRegister({
    super.key,
    required this.desdeAdmin,
    this.cedula,
    this.nombreCompleto,
  });

  @override
  State<PayRegister> createState() => _PayRegisterState();
}

class _PayRegisterState extends State<PayRegister> {
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  bool isCedulaFocused = false;

  @override
  void initState() {
    super.initState();
    if (!widget.desdeAdmin) {
      cedulaController.text = widget.cedula ?? '';
      nombreController.text = widget.nombreCompleto ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos del registro',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
        
                  const SizedBox(
                    height: 20,
                  ),
                  // Cedula
                  TextFormField(
                    controller: cedulaController,
                    readOnly: !widget.desdeAdmin,
                    onTap: () {
                      if (widget.desdeAdmin) {
                        setState(() => isCedulaFocused = true);
                      }
                    },
                    onChanged: (_) {
                      if (widget.desdeAdmin) {
                        setState(() => isCedulaFocused = true);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Cédula',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(
                        widget.desdeAdmin
                            ? (isCedulaFocused ? Icons.search : Icons.credit_card)
                            : Icons.credit_card,
                      ),
                      fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                      filled: true,
                    ),
                  ),
        
                  const SizedBox(height: 15),
        
                  // Nombre completo
                  TextFormField(
                    controller: nombreController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Nombre Completo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.account_circle),
                      fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                      filled: true,
                    ),
                  ),
        
                  const SizedBox(height: 30),
        
                  // Widget de Membresía
                 const Membership(),
                ],
              ),
            ),
          ),
      ),
      );
  }
}
