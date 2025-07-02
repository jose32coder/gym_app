// ignore_for_file: use_build_context_synchronously

import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/components/validations.dart';
import 'package:basic_flutter/models/model_membership.dart';
import 'package:basic_flutter/viewmodel/membership_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MembershipForm extends StatefulWidget {
  final MembershipModel? membershipEdit;

  const MembershipForm({super.key, this.membershipEdit});

  @override
  State<MembershipForm> createState() => _MembershipFormState();
}

class _MembershipFormState extends State<MembershipForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  late FocusNode _nameFocusNode;
  late FocusNode _priceFocusNode;
  late FocusNode _tipoMemberFocus;

  String? _nameError;
  String? _priceError;
  String? _tipoMemberError;

  String membership = '';
  final uid = FirebaseAuth.instance.currentUser?.uid;
  bool showDiscounts = false;
  bool hasPromotion = false;
  double promotionDiscount = 0;

  bool isActive = true;

  final List<String> membershipTypes = [
    'Diario',
    'Semanal',
    'Quincenal',
    'Mensual',
    'Trimestral',
    'Semestral',
    'Anual',
  ];

  @override
  void initState() {
    super.initState();

    _nameFocusNode = FocusNode();
    _priceFocusNode = FocusNode();
    _tipoMemberFocus = FocusNode();

    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        setState(() {
          _nameError = Validations.validateMembershipName(_nameController.text);
        });
      }
    });
    _priceFocusNode.addListener(() {
      if (!_priceFocusNode.hasFocus) {
        setState(() {
          _priceError = Validations.validatePrice(_priceController.text);
        });
      }
    });
    _tipoMemberFocus.addListener(() {
      if (!_tipoMemberFocus.hasFocus) {
        setState(() {
          _tipoMemberError = Validations.validateTipoMember(membership);
        });
      }
    });

    if (widget.membershipEdit != null) {
      final m = widget.membershipEdit!;
      _nameController.text = m.name;
      _priceController.text = m.price.toString();
      membership = m.membershipType;
      isActive = m.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _registerMembership() async {
    final membershipVM =
        Provider.of<MembershipViewmodel>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    setState(() {
      _nameError = Validations.validateMembershipName(_nameController.text);
    });

    if (_formKey.currentState!.validate() &&
        _nameError == null &&
        _priceError == null &&
        _tipoMemberError == null) {
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
        return;
      }

      final priceParsed = double.tryParse(_priceController.text.trim());
      if (priceParsed == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Precio inválido')),
        );
        return;
      }

      final newMembership = MembershipModel(
        name: _nameController.text.trim(),
        price: priceParsed,
        membershipType: membership,
        isActive: isActive,
      );

      try {
        await membershipVM.guardarMembresia(
          usuarioId: uid,
          membership: newMembership,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membresía guardada correctamente')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar membresía: $e')),
        );
      }
    }
  }

  void _actualizarMembership() async {
    final membershipVM =
        Provider.of<MembershipViewmodel>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
    }

    final priceParsed = double.tryParse(_priceController.text.trim());
    if (priceParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Precio inválido')),
      );
      return;
    }

    final updatedMembership = MembershipModel(
      name: _nameController.text.trim(),
      price: priceParsed,
      membershipType: membership,
      isActive: isActive,
    );

    try {
      await membershipVM.actualizarMembresia(
        usuarioId: uid,
        membershipId: widget.membershipEdit?.id ??
            'id_no_disponible', // Este debes tenerlo ya definido
        membership: updatedMembership,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Membresía actualizada correctamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar membresía: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.membershipEdit == null
              ? 'Nueva membresía'
              : 'Editar membresía',
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                elevation: 4.0,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Nombre',
                          style: TextStyles.boldText(context),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          decoration: inputDecoration(
                            isDarkMode: isDarkMode,
                            prefixIcon: Icons.person_outline,
                            hintText: 'Introduce el nombre',
                          ).copyWith(
                            errorText: _nameError,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _nameError =
                                  Validations.validateMembershipName(value);
                            });
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: Validations.validateMembershipName,
                        ),
                        const SizedBox(height: 15),

                        /// Precio
                        Text(
                          'Precio',
                          style: TextStyles.boldText(context),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: _priceController,
                          focusNode: _priceFocusNode,
                          keyboardType: TextInputType.number,
                          decoration: inputDecoration(
                            isDarkMode: isDarkMode,
                            prefixIcon: Icons.attach_money,
                            hintText: 'Introduce el precio',
                          ).copyWith(
                            errorText: _priceError,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _priceError = Validations.validatePrice(value);
                            });
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: Validations.validatePrice,
                        ),

                        const SizedBox(height: 15),

                        /// Tipo de membresía
                        Text(
                          'Tipo',
                          style: TextStyles.boldText(context),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        DropdownButtonFormField<String>(
                          value: membership.isNotEmpty ? membership : null,
                          focusNode: _tipoMemberFocus,
                          decoration: inputDecoration(
                            isDarkMode: isDarkMode,
                            prefixIcon: Icons.assignment,
                            hintText: 'Tipo de membresía',
                            error: _tipoMemberError,
                          ),
                          items: membershipTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              membership = value ?? '';
                              _tipoMemberError = null;
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        /// Switch Activo
                        SwitchListTile(
                          title: Text(
                            'Activo',
                            style: theme.textTheme.titleMedium,
                          ),
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        const Divider(height: 40),

                        /// Botones
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  widget.membershipEdit == null
                                      ? _registerMembership()
                                      : _actualizarMembership();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.add,
                                  color: isDarkMode
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onInverseSurface,
                                ),
                                label: Text(
                                  widget.membershipEdit == null
                                      ? 'Registrar'
                                      : 'Actualizar',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onInverseSurface,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _formKey.currentState?.reset();
                                  setState(() {
                                    membership = '';
                                    hasPromotion = false;
                                    promotionDiscount = 0;
                                    isActive = true;
                                  });
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.cancel,
                                  color: isDarkMode
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onInverseSurface,
                                ),
                                label: Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onInverseSurface,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.error,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration inputDecoration(
    {required bool isDarkMode,
    required IconData prefixIcon,
    required String hintText,
    String? error}) {
  return InputDecoration(
      prefixIcon: Icon(prefixIcon),
      hintText: hintText,
      filled: true,
      fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      errorText: error);
}
