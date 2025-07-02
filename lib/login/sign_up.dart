// ignore_for_file: use_build_context_synchronously

import 'package:basic_flutter/components/validations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:basic_flutter/viewmodel/auth_viewmodel.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cedController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptPolicy = false;
  bool isLoading = false;
  int _currentStep = 0;

  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _nameFocusNode;
  late FocusNode _lastnameFocusNode;
  late FocusNode _cedFocusNode;

  String? _emailError;
  String? _passwordError;
  String? _nameError;
  String? _cedError;
  String? _lastnameError;
  String? _selectedSexo;
  String? _sexoError;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
    _cedFocusNode = FocusNode();
    _lastnameFocusNode = FocusNode();

    // Escuchar pérdida de foco y validar
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateStep1() {
    setState(() {
      _cedError = Validations.validateCed(_cedController.text);
      _nameError = Validations.validateName(_nameController.text);
      _lastnameError = Validations.validateName(_lastnameController.text);
      _sexoError = _selectedSexo == null ? 'Debes seleccionar un sexo' : null;
    });

    return _cedError == null && _nameError == null && _lastnameError == null;
  }

  bool _validateStep2() {
    setState(() {
      _emailError = Validations.validateEmail(_emailController.text);
      _passwordError = Validations.validatePassword(_passwordController.text);
    });

    return _emailError == null && _passwordError == null;
  }

  void _register() async {
    final authViewModel = Provider.of<AuthViewmodel>(context, listen: false);
    setState(() {
      _emailError = Validations.validateEmail(_emailController.text);
      _passwordError = Validations.validatePassword(_passwordController.text);
      _cedError = Validations.validateCed(_cedController.text);
      _nameError = Validations.validateName(_nameController.text);
      _lastnameError = Validations.validateName(_lastnameController.text);
    });

    if (_formKey.currentState!.validate() &&
        _emailError == null &&
        _passwordError == null &&
        _cedError == null &&
        _nameError == null &&
        _lastnameError == null &&
        _sexoError == null) {
      setState(() {
        isLoading = true;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await Future.delayed(const Duration(seconds: 1)); // demo

        await authViewModel.register(
          ced: _cedController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          lastname: _lastnameController.text.trim(),
          sexo: _selectedSexo,
        );

        if (authViewModel.errorMessage == null) {
          // Registro exitoso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro exitoso')),
          );
          // No navegas aquí porque el StreamBuilder en main detecta el usuario
        } else {
          // Mostrar error que dio Firebase
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authViewModel.errorMessage!)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inesperado')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop(); // cierra el loading dialog

        if (authViewModel.errorMessage == null) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    InputDecoration inputDecoration(String hint, Icon icon) {
      return InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: icon,
        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
        filled: true,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Column(
                  children: [
                    Text(
                      _currentStep == 0 ? 'Hola,' : 'Ahora,',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _currentStep == 0
                          ? 'Registremos tu cuenta'
                          : 'Correo y contraseña',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      final inAnimation = Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation);

                      return SlideTransition(
                        position: inAnimation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: _currentStep == 0
                        ? Column(
                            key: const ValueKey<int>(0),
                            children: [
                              TextFormField(
                                controller: _cedController,
                                focusNode: _cedFocusNode,
                                decoration: inputDecoration(
                                  'Cédula',
                                  const Icon(Icons.badge, size: 24),
                                ).copyWith(
                                  errorText: _cedError,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _cedError = Validations.validateCed(value);
                                  });
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: Validations.validateCed,
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              TextFormField(
                                controller: _nameController,
                                focusNode: _nameFocusNode,
                                decoration: inputDecoration(
                                  'Nombre',
                                  const Icon(Icons.person, size: 24),
                                ).copyWith(
                                  errorText: _nameError,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _nameError =
                                        Validations.validateName(value);
                                  });
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: Validations.validateName,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _lastnameController,
                                focusNode: _lastnameFocusNode,
                                decoration: inputDecoration(
                                  'Apellido',
                                  const Icon(Icons.person, size: 24),
                                ).copyWith(
                                  errorText: _lastnameError,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _lastnameError =
                                        Validations.validateName(value);
                                  });
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: Validations.validateName,
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              DropdownButtonFormField<String>(
                                value: _selectedSexo,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                  prefixIcon: const Icon(Icons.person_outline),
                                  errorText: _sexoError,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: null,
                                      child: Text('Selecciona un sexo')),
                                  DropdownMenuItem(
                                      value: 'Masculino',
                                      child: Text('Masculino')),
                                  DropdownMenuItem(
                                      value: 'Femenino',
                                      child: Text('Femenino')),
                                  DropdownMenuItem(
                                      value: 'Otro', child: Text('Otro')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSexo = value;
                                    _sexoError = null;
                                  });
                                },
                              )
                            ],
                          )
                        : Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                decoration: inputDecoration(
                                  'Correo',
                                  const Icon(Icons.email_rounded, size: 24),
                                ).copyWith(
                                  errorText: _emailError,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _emailError =
                                        Validations.validateEmail(value);
                                  });
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: Validations.validateEmail,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                obscureText: _obscurePassword,
                                decoration: inputDecoration(
                                  'Contraseña',
                                  const Icon(Icons.lock, size: 24),
                                )
                                    .copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    )
                                    .copyWith(
                                      errorText: _passwordError,
                                    ),
                                onChanged: (value) {
                                  setState(() {
                                    _passwordError =
                                        Validations.validatePassword(value);
                                  });
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: Validations.validatePassword,
                              ),
                              const SizedBox(height: 8),
                              CheckboxListTile(
                                value: _acceptPolicy,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptPolicy = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'Acepto las políticas de privacidad',
                                  style: TextStyle(fontSize: 14),
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                dense: true,
                              ),
                            ],
                          ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _currentStep--;
                              });
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: isDarkMode
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onInverseSurface,
                            ),
                            label: Text(
                              'Volver',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onInverseSurface,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_currentStep == 0) {
                              if (_validateStep1() &&
                                  _formKey.currentState!.validate()) {
                                setState(() {
                                  _currentStep++;
                                });
                              }
                            } else if (_currentStep == 1) {
                              if (_validateStep2() &&
                                  _formKey.currentState!.validate()) {
                                _register();
                              }
                            }
                          },
                          icon: Icon(
                            _currentStep == 0
                                ? Icons.arrow_forward
                                : Icons.login,
                            color: isDarkMode
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onInverseSurface,
                          ),
                          label: Text(
                            _currentStep == 0 ? 'Siguiente' : 'Registrar',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onInverseSurface,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'O',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.white,
                      elevation: 3,
                    ),
                    child: Image.asset(
                      'assets/images/google.png',
                      height: 24,
                      width: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes una cuenta?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
