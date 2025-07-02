import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/components/validations.dart';
import 'package:basic_flutter/viewmodel/person_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Importa tu ViewModel o proveedor aquí
import 'package:provider/provider.dart';

class PrefAccountAndData extends StatefulWidget {
  const PrefAccountAndData({super.key});

  @override
  State<PrefAccountAndData> createState() => _PrefAccountAndDataState();
}

class _PrefAccountAndDataState extends State<PrefAccountAndData> {
  bool isEditing = false;
  bool isLoading = false; // Para control de carga
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final lastnameController = TextEditingController();
  final phoneController = TextEditingController();
  final cedController = TextEditingController();
  final heightController = TextEditingController();
  final extraPhoneController = TextEditingController();
  String? selectedGender;

  String? _nameError;
  String? _lastnameError;
  String? _phoneError;
  String? _cedError;

  late FocusNode _cedFocusNode;
  late FocusNode _nameFocusNode;
  late FocusNode _lastnameFocusNode;
  late FocusNode _phoneFocusNode;

  // Aquí asigna dinámicamente los ids de usuario y gimnasio
  final uid = FirebaseAuth.instance.currentUser!.uid;

  void showNotificationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const NotificationModal(),
    );
  }

  @override
  void initState() {
    super.initState();

    _cargarDatos();

    _cedFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
    _lastnameFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();

    // Escuchar pérdida de foco y validar
    _cedFocusNode.addListener(() {
      if (!_cedFocusNode.hasFocus) {
        setState(() {
          _cedError = Validations.validateCed(cedController.text);
        });
      }
    });

    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        setState(() {
          _nameError = Validations.validateName(nameController.text);
        });
      }
    });
    _lastnameFocusNode.addListener(() {
      if (!_lastnameFocusNode.hasFocus) {
        setState(() {
          _lastnameError = Validations.validateName(lastnameController.text);
        });
      }
    });
    _phoneFocusNode.addListener(() {
      if (!_phoneFocusNode.hasFocus) {
        setState(() {
          _phoneError = Validations.validatePhone(phoneController.text);
        });
      }
    });
  }

  @override
  void dispose() {
    _cedFocusNode.dispose();
    _nameFocusNode.dispose();
    _lastnameFocusNode.dispose();
    _phoneFocusNode.dispose();

    cedController.dispose();
    nameController.dispose();
    lastnameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    final theme = Theme.of(context);

    setState(() {
      _cedError = Validations.validateCed(cedController.text);
      _nameError = Validations.validateName(nameController.text);
      _lastnameError = Validations.validateName(lastnameController.text);
      _phoneError = Validations.validatePhone(phoneController.text);
    });

    if (_cedError != null ||
        _nameError != null ||
        _lastnameError != null ||
        _phoneError != null ||
        !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: theme.colorScheme.error,
            content: Text(
              'Rellena los campos correctamente',
              style: TextStyle(color: theme.colorScheme.onSurface),
            )),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final datosCompletos = {
      'cedula': cedController.text.trim(),
      'nombre': nameController.text.trim(),
      'apellido': lastnameController.text.trim(),
      'telefono': phoneController.text.trim(),
      'altura': heightController.text.trim(),
      'sexo': selectedGender ?? '',
    };

    try {
      final viewModel = Provider.of<PersonasViewModel>(context, listen: false);
      final gimnasioId = await viewModel.obtenerGimnasioIdUsuario();

      await viewModel.actualizarDatosUsuario(
        usuarioId: uid,
        gimnasioId: gimnasioId,
        datosCompletos: datosCompletos,
      );

      if (viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage!)),
        );
      } else {
        setState(() {
          isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos actualizados correctamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _cargarDatos() async {
    setState(() {
      isLoading = true;
    });

    try {
      final viewModel = Provider.of<PersonasViewModel>(context, listen: false);
      final gimnasioId = await viewModel.obtenerGimnasioIdUsuario();

      final data = await viewModel.obtenerDocumentoEnSubcoleccion(
        coleccionPadre: 'gimnasios',
        docPadreId: gimnasioId,
        subcoleccion: 'usuarios',
        docHijoId: uid,
      );

      if (data != null) {
        nameController.text = data['nombre'] ?? '';
        lastnameController.text = data['apellido'] ?? '';
        cedController.text = data['cedula'] ?? '';
        phoneController.text = data['telefono'] ?? '';
        heightController.text = data['talla'] ?? '';
        final genero = data['sexo'];
        if (genero == 'Hombre' || genero == 'Mujer' || genero == 'Otro') {
          selectedGender = genero;
        } else {
          selectedGender = null;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          'Cuenta y Datos',
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.bell),
              onPressed: () {
                showNotificationModal(context);
              },
            ),
          )
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 70,
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                    ),
                    if (isEditing)
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt,
                              color: theme.colorScheme.primary),
                          onPressed: () {
                            // Cambiar foto
                          },
                        ),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cédula',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: cedController,
                      focusNode: _cedFocusNode,
                      enabled: isEditing,
                      keyboardType: TextInputType.number,
                      decoration: inputDecoration(
                        'Cédula',
                        const Icon(Icons.badge),
                      ).copyWith(errorText: _cedError),
                      onChanged: (value) {
                        setState(() {
                          _cedError = Validations.validateCed(value);
                        });
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: Validations.validateCed,
                    ),
                    const SizedBox(height: 20),
                    const Text('Nombre',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      focusNode: _nameFocusNode,
                      enabled: isEditing,
                      decoration: inputDecoration(
                        'Nombre',
                        const Icon(Icons.person),
                      ).copyWith(errorText: _nameError),
                      onChanged: (value) {
                        setState(() {
                          _nameError = Validations.validateName(value);
                        });
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: Validations.validateName,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text('Apellido',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: lastnameController,
                      focusNode: _lastnameFocusNode,
                      enabled: isEditing,
                      decoration: inputDecoration(
                        'Apellido',
                        const Icon(Icons.person),
                      ).copyWith(errorText: _lastnameError),
                      onChanged: (value) {
                        setState(() {
                          _lastnameError = Validations.validateName(value);
                        });
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: Validations.validateName,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Teléfono',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: phoneController,
                      focusNode: _phoneFocusNode,
                      enabled: isEditing,
                      keyboardType: TextInputType.phone,
                      decoration: inputDecoration(
                        'Teléfono',
                        const Icon(Icons.phone),
                      ).copyWith(errorText: _phoneError),
                      onChanged: (value) {
                        setState(() {
                          _phoneError = Validations.validatePhone(value);
                        });
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: Validations.validatePhone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              if (isLoading) const Center(child: CircularProgressIndicator()),
              if (!isEditing && !isLoading)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Datos'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              if (isEditing && !isLoading)
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _guardarCambios,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Cambios'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: isDarkMode
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onInverseSurface,
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                        });
                      },
                      icon: Icon(Icons.cancel,
                          color: isDarkMode
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onInverseSurface),
                      label: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: isDarkMode
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onInverseSurface,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration inputDecoration(String label, Icon icon) {
  return InputDecoration(
    prefixIcon: icon,
    hintText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  );
}
