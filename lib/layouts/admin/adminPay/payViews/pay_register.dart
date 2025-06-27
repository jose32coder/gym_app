import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/admin/adminPay/widgets/membership.dart';
import 'package:basic_flutter/viewmodel/person_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class PayRegister extends StatefulWidget {
  final bool desdeAdmin;
  final String? cedula;
  final String? nombre;

  const PayRegister({
    super.key,
    required this.desdeAdmin,
    this.cedula,
    this.nombre,
  });

  @override
  State<PayRegister> createState() => _PayRegisterState();
}

class _PayRegisterState extends State<PayRegister> {
  final TextEditingController cedulaController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  bool isCedulaFocused = false;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  List<Map<String, dynamic>> usuariosEncontrados = [];
  String nombreAsociado = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuariosViewModel =
          Provider.of<PersonasViewModel>(context, listen: false);
      usuariosViewModel.cargarUsuarios();
    });

    if (!widget.desdeAdmin) {
      cedulaController.text = widget.cedula ?? '';
      nombreAsociado = widget.nombre ?? '';
    }
  }

  void _showOverlay(List<Map<String, dynamic>> usuarios) {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 40,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).cardColor,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return ListTile(
                  title: Text('${usuario['nombre'] ?? ''}'),
                  subtitle: Text('Cédula: ${usuario['cedula'] ?? ''}'),
                  onTap: () {
                    cedulaController.text = usuario['cedula'] ?? '';
                    setState(() {
                      nombreAsociado = '${usuario['nombre'] ?? ''}';
                    });
                    _removeOverlay();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> buscarUsuariosPorCedula(String value) async {
    final usuariosViewModel =
        Provider.of<PersonasViewModel>(context, listen: false);

    final gimnasioId = usuariosViewModel.gimnasioId;
    if (gimnasioId == null || gimnasioId.isEmpty) {
      print('Gimnasio ID no disponible');
      return;
    }

    final usuarios = await usuariosViewModel.buscarUsuariosPorCedulaEnGimnasio(
        gimnasioId, value);

    if (usuarios.isNotEmpty) {
      usuariosEncontrados = usuarios;
      setState(() {
        nombreAsociado =
            '${usuarios.first['nombre'] ?? ''} ${usuarios.first['apellido'] ?? ''}';
      });
      _showOverlay(usuarios);
    } else {
      setState(() {
        nombreAsociado = '';
      });
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    cedulaController.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nuevo pago',
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.bell),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const NotificationModal(),
                );
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cédula',
                style: TextStyles.boldPrimaryText(context),
              ),
              const SizedBox(height: 5),
              CompositedTransformTarget(
                link: _layerLink,
                child: TextFormField(
                  controller: cedulaController,
                  readOnly: widget.desdeAdmin,
                  onTap: () {
                    if (widget.desdeAdmin) {
                      setState(() => isCedulaFocused = true);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        buscarUsuariosPorCedula('');
                      });
                    }
                  },
                  onChanged: (value) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      buscarUsuariosPorCedula(value);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cédula',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(
                      widget.desdeAdmin
                          ? (isCedulaFocused ? Icons.search : Icons.credit_card)
                          : Icons.credit_card,
                    ),
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        nombreAsociado,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                    filled: true,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Widget de Membresía
              const Membership(),
            ],
          ),
        ),
      ),
    );
  }
}
