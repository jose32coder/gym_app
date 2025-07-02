import 'dart:math';

import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/components/validations.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/pay_register.dart';
import 'package:basic_flutter/viewmodel/person_viewmodel.dart';
import 'package:basic_flutter/viewmodel/user_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextFormPage extends StatefulWidget {
  const TextFormPage({
    super.key,
  });

  @override
  State<TextFormPage> createState() => _TextFormPageState();
}

class _TextFormPageState extends State<TextFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cedController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  // FocusNodes para detectar pérdida de foco
  late FocusNode _cedFocusNode;
  late FocusNode _nameFocusNode;
  late FocusNode _lastnameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _codeFocusNode;
  late FocusNode _sexoFocusNode;
  late FocusNode _rolFocusNode;

  bool isLoading = false;
  // Variables para almacenar mensajes de error en tiempo real
  String? _cedError;
  String? _nameError;
  String? _lastnameError;
  String? _emailError;
  String? _sexoError;
  String? _rolError;
  String? _selectedSexo;
  String? _passwordError;
  String? _selectedRol;
  String? _codeError;
  String? uid;

  @override
  void initState() {
    super.initState();
    _cedFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
    _lastnameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _codeFocusNode = FocusNode();
    _sexoFocusNode = FocusNode();
    _rolFocusNode = FocusNode();

    // Escuchar pérdida de foco y validar
    _cedFocusNode.addListener(() {
      if (!_cedFocusNode.hasFocus) {
        setState(() {
          _cedError = Validations.validateCed(_cedController.text);
        });
      }
    });

    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        setState(() {
          _nameError = Validations.validateName(_nameController.text);
        });
      }
    });
    _lastnameFocusNode.addListener(() {
      if (!_lastnameFocusNode.hasFocus) {
        setState(() {
          _lastnameError = Validations.validateName(_lastnameController.text);
        });
      }
    });
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        setState(() {
          _emailError = Validations.validateEmail(_emailController.text);
        });
      }
    });
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        setState(() {
          _passwordError =
              Validations.validatePassword(_passwordController.text);
        });
      }
    });
    _sexoFocusNode.addListener(() {
      if (!_sexoFocusNode.hasFocus) {
        setState(() {
          _sexoError = Validations.validateSex(_selectedSexo);
        });
      }
    });
    _rolFocusNode.addListener(() {
      if (!_rolFocusNode.hasFocus) {
        setState(() {
          _rolError = Validations.validateSex(_selectedRol);
        });
      }
    });
    _codeFocusNode.addListener(() {
      if (!_codeFocusNode.hasFocus) {
        setState(() {
          _codeError = Validations.validateCode(_codeController.text);
        });
      }
    });
  }

  @override
  void dispose() {
    _cedFocusNode.dispose();
    _rolFocusNode.dispose();
    _lastnameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _sexoFocusNode.dispose();
    _codeFocusNode.dispose();

    _cedController.dispose();
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String generarCodigoAleatorio(int longitud) {
    const caracteres = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        longitud,
        (_) => caracteres.codeUnitAt(random.nextInt(caracteres.length)),
      ),
    );
  }

  Future<void> obtenerCodigoGimnasio() async {
    try {
      final userViewModel = Provider.of<UserViewmodel>(context, listen: false);
      uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        final codigo = await userViewModel.obtenerCodigoGimnasio(uid!);

        if (mounted) {
          final codigoRecortado =
              codigo.length >= 8 ? codigo.substring(0, 8) : codigo;
          final codigoAleatorio = generarCodigoAleatorio(5);
          final codigoFinal = '$codigoRecortado-$codigoAleatorio';

          setState(() {
            _codeError = null;
            _codeController.text = codigoFinal;
          });
        }
      } else {
        debugPrint("No hay usuario autenticado.");
      }
    } catch (e) {
      debugPrint("Error al obtener código gimnasio: $e");
    }
  }

  void _registerClient() async {
    final personVM = Provider.of<PersonasViewModel>(context, listen: false);

    final nuevoUsuarioId = await personVM.registerNewUserFromAdmin(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      lastname: _lastnameController.text.trim(),
      cedula: _cedController.text.trim(),
      sexo: _selectedSexo,
      codeGym: _codeController.text.trim(),
      tipo: _selectedRol,
    );

    // Aquí ya tienes el uid como String
    await personVM.asociarUsuarioAGimnasioPorCodigo(
      usuarioId: nuevoUsuarioId,
      tipoUsuario: _selectedRol,
      talla: '',
      peso: '',
      membresia: '',
      pago: '',
      codeGym: _codeController.text.trim(),
    );
  }

  void _actionClient() async {
    setState(() {
      _cedError = Validations.validateCed(_cedController.text);
      _nameError = Validations.validateName(_nameController.text);
      _lastnameError = Validations.validateName(_lastnameController.text);
      _emailError = Validations.validateEmail(_emailController.text);
      _passwordError = Validations.validatePassword(_passwordController.text);
      _sexoError = _selectedSexo == null ? 'Debes seleccionar un sexo' : null;
      _rolError = _selectedRol == null ? 'Debes seleccionar un rol' : null;
    });

    if (_formKey.currentState!.validate() &&
        _cedError == null &&
        _nameError == null &&
        _lastnameError == null &&
        _emailError == null &&
        _sexoError == null &&
        _rolError == null &&
        _passwordError == null) {
      setState(() {
        isLoading = true;
      });

      final bool? pagarAhora = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Deseas pagar la membresía ahora?'),
          actions: [
            TextButton(
              onPressed: () async {
                _registerClient();
                Navigator.of(context).pop(false);
              },
              child: const Text('Solo registrar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Pagar ahora'),
            ),
          ],
        ),
      );

      if (pagarAhora != null) {
        if (pagarAhora) {
          // Navegar a Membership con pagoInmediato = true
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PayRegister(
                desdeAdmin: false,
                cedula: '12345678',
                nombre: 'Jose Perez',
              ),
            ),
          );
        } else {
          // Solo registro sin pago
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Persona registrada sin membresía')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos correctamente'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cédula',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
              controller: _cedController,
              focusNode: _cedFocusNode,
              decoration: InputDecoration(
                hintText: 'Introduce la cédula',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.badge),
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                filled: true,
              ).copyWith(errorText: _cedError),
              onChanged: (value) {
                setState(() {
                  _cedError = Validations.validateCed(value);
                });
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validations.validateCed),
          const SizedBox(height: 20),
          Text(
            'Nombre',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            decoration: InputDecoration(
              hintText: 'Introduce el nombre',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.account_circle),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
            ).copyWith(errorText: _nameError),
            onChanged: (value) {
              setState(() {
                _nameError = Validations.validateName(value);
              });
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: Validations.validateName,
          ),
          const SizedBox(height: 15),
          Text(
            'Apellido',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _lastnameController,
            focusNode: _lastnameFocusNode,
            decoration: InputDecoration(
              hintText: 'Introduce el apellido',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.account_circle),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
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
          Text(
            'Sexo',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: _selectedSexo,
            focusNode: _sexoFocusNode,
            hint: const Text('Selecciona un sexo'),
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              prefixIcon: const Icon(Icons.person_outline),
              errorText: _sexoError,
            ),
            items: const [
              DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
              DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
              DropdownMenuItem(value: 'Otro', child: Text('Otro')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSexo = value;
                _sexoError = null;
              });
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Rol',
            style: TextStyles.boldText(context),
          ),
          DropdownButtonFormField<String>(
            value: _selectedRol,
            focusNode: _rolFocusNode,
            hint: const Text('Selecciona un rol'),
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              prefixIcon: const Icon(Icons.person_outline),
              errorText: _rolError,
            ),
            items: const [
              DropdownMenuItem(
                  value: 'Administrador', child: Text('Administrador')),
              DropdownMenuItem(value: 'Entrenador', child: Text('Entrenador')),
              DropdownMenuItem(value: 'Cliente', child: Text('Cliente')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedRol = value;
                _rolError = null;
              });
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Correo',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            decoration: InputDecoration(
              hintText: 'Correo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.email_rounded),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
            ).copyWith(errorText: _emailError),
            onChanged: (value) {
              setState(() {
                _emailError = Validations.validateEmail(value);
              });
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: Validations.validateEmail,
          ),
          const SizedBox(height: 20),
          Text(
            'Contraseña',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            decoration: InputDecoration(
              hintText: 'Contraseña',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.lock_rounded),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
            ).copyWith(errorText: _passwordError),
            onChanged: (value) {
              setState(() {
                _passwordError = Validations.validatePassword(value);
              });
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: Validations.validatePassword,
          ),
          const SizedBox(height: 20),
          Text(
            'Codigo',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Alinea por arriba
            children: [
              Expanded(
                child: SizedBox(
                  height: 80, // Altura fija suficiente para input + error
                  child: TextFormField(
                    controller: _codeController,
                    focusNode: _codeFocusNode,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Codigo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.qr_code),
                      fillColor:
                          isDarkMode ? Colors.grey.shade800 : Colors.white,
                      filled: true,
                      errorText: _codeError,
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: Validations.validateCode,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 55,
                width: 55,
                child: ElevatedButton(
                  onPressed: obtenerCodigoGimnasio,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.qr_code,
                      color: isDarkMode
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onInverseSurface,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _actionClient,
              icon: Icon(
                Icons.login,
                color: isDarkMode
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onInverseSurface,
              ),
              label: Text(
                'Registrar',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onInverseSurface,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}
