import 'package:basic_flutter/components/validations.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter/login/sign_in.dart';
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

  bool _obscurePassword = true;
  bool _acceptPolicy = false;
  bool isLoading = false;

  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _nameFocusNode;
  late FocusNode _lastnameFocusNode;

  String? _emailError;
  String? _passwordError;
  String? _nameError;
  String? _lastnameError;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
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

  void _register() async {
    final authViewModel = Provider.of<AuthViewmodel>(context, listen: false);
    setState(() {
      _emailError = Validations.validateEmail(_emailController.text);
      _passwordError = Validations.validatePassword(_passwordController.text);
      _nameError = Validations.validateName(_nameController.text);
      _lastnameError = Validations.validateName(_lastnameController.text);
    });

    if (_formKey.currentState!.validate() &&
        _emailError == null &&
        _passwordError == null &&
        _nameError == null &&
        _lastnameError == null) {
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
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          lastname: _lastnameController.text.trim(),
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
                const Column(
                  children: [
                    Text('Hola,', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 5),
                    Text(
                      'Registremos tu cuenta',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                            _nameError = Validations.validateName(value);
                          });
                        },
                        validator: Validations.validateName,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _lastnameController,
                        focusNode: _lastnameFocusNode,
                        decoration: inputDecoration(
                          'Apellido',
                          const Icon(Icons.person_outline, size: 24),
                        ).copyWith(
                          errorText: _lastnameError,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _lastnameError = Validations.validateName(value);
                          });
                        },
                        validator: Validations.validateName,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        decoration: inputDecoration(
                          'Correo o usuario',
                          const Icon(Icons.email_rounded, size: 24),
                        ).copyWith(
                          errorText: _emailError,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _emailError = Validations.validateEmail(value);
                          });
                        },
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
                                    _obscurePassword = !_obscurePassword;
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
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _register,
                    icon: const Icon(Icons.login),
                    label: const Text(
                      'Registrar',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignIn()),
                        );
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
