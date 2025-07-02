import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/components/validations.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/widgets/admin_pay_form.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController cedController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  bool isCedulaFocused = false;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late FocusNode _cedFocusNode;

  List<Map<String, dynamic>> usuariosEncontrados = [];
  String nombreAsociado = '';
  String? _cedError;

  @override
  void initState() {
    super.initState();

    _cedFocusNode = FocusNode();

    _cedFocusNode.addListener(() {
      if (!_cedFocusNode.hasFocus) {
        setState(() {
          _cedError = Validations.validateCed(cedController.text);
        });
        _removeOverlay(); // Cierra overlay al perder foco
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuariosViewModel =
          Provider.of<PersonasViewModel>(context, listen: false);
      usuariosViewModel.cargarUsuarios();
    });

    if (!widget.desdeAdmin) {
      cedController.text = widget.cedula ?? '';
      nombreAsociado = widget.nombre ?? '';
      nombreController.text = nombreAsociado;
    }
  }

  void _showOverlay(List<Map<String, dynamic>> usuarios) {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Cierra el overlay al hacer tap fuera
          _removeOverlay();
          FocusScope.of(context).unfocus(); // Oculta teclado si estaba abierto
        },
        child: Stack(
          children: [
            Positioned(
              width: MediaQuery.of(context).size.width - 40,
              height: MediaQuery.of(context).size.height / 2,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, 80),
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
                          cedController.text = usuario['cedula'] ?? '';
                          nombreController.text =
                              '${usuario['nombre'] ?? ''} ${usuario['apellido'] ?? ''}';

                          setState(() {
                            nombreAsociado = '${usuario['nombre'] ?? ''}';
                          });
                          _removeOverlay();
                          FocusScope.of(context)
                              .unfocus(); // Oculta teclado tras selección
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
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

    final gimnasioId = await usuariosViewModel.obtenerGimnasioIdUsuario();

    if (gimnasioId == null || gimnasioId.isEmpty) {
      print('Gimnasio ID no disponible');
      return;
    }

    // No buscar ni mostrar overlay si el campo está vacío
    if (value.trim().isEmpty) {
      usuariosEncontrados = [];
      _removeOverlay();
      return;
    }

    final usuarios = await usuariosViewModel.buscarUsuariosPorCedulaEnGimnasio(
        gimnasioId, value);

    if (usuarios.isNotEmpty) {
      usuariosEncontrados = usuarios;
      _showOverlay(usuarios);
    } else {
      usuariosEncontrados = [];
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    cedController.dispose();
    _cedFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

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
                style: TextStyles.boldText(context),
              ),
              const SizedBox(height: 5),
              CompositedTransformTarget(
                link: _layerLink,
                child: TextFormField(
                  focusNode: _cedFocusNode,
                  keyboardType: TextInputType.number,
                  controller: cedController,
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
                    setState(() {
                      _cedError = Validations.validateCed(value);
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
                          color: isDarkMode
                              ? theme.colorScheme.onInverseSurface
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    fillColor: theme.colorScheme.onInverseSurface,
                    filled: true,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validations.validateCed,
                ),
              ),

              const SizedBox(height: 15),

              // Widget de pago de membresía
              AdminPayForm(
                formKey: _formKey,
                cedulaController: cedController,
                nombreController: nombreController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
