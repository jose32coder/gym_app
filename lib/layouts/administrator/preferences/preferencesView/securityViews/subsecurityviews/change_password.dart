import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/components/validations.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/securityViews/subsecurityviews/widgets/password_file.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/securityViews/subsecurityviews/widgets/switch_tile.dart';
import 'package:basic_flutter/viewmodel/auth_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Tus checkboxes: se mantienen intactos
  bool _twoStepAuth = false;
  bool _lockWithPin = false;

  late final FocusNode _passwordFocusNode;
  late final FocusNode _newPasswordFocusNode;
  late final FocusNode _confirmPasswordFocusNode;

  String? _passwordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  String? _currentUserPasswordCache;

  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode()..addListener(_onPasswordFocusChange);
    _newPasswordFocusNode = FocusNode()..addListener(_onNewPasswordFocusChange);
    _confirmPasswordFocusNode = FocusNode()
      ..addListener(_onConfirmPasswordFocusChange);
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordFocusChange() {
    if (!_passwordFocusNode.hasFocus) _validateCurrentPassword();
  }

  void _onNewPasswordFocusChange() {
    if (!_newPasswordFocusNode.hasFocus) _validateNewPassword();
  }

  void _onConfirmPasswordFocusChange() {
    if (!_confirmPasswordFocusNode.hasFocus) _validateConfirmPassword();
  }

  Future<void> _validateCurrentPassword() async {
    final user = _auth.currentUser;
    final email = user?.email;
    final password = _passwordController.text.trim();

    if (email == null) return;

    try {
      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      await user!.reauthenticateWithCredential(credential);
      setState(() {
        _passwordError = null;
        _currentUserPasswordCache = password;
      });
    } on FirebaseAuthException {
      setState(() => _passwordError = 'Contraseña actual incorrecta');
    }
  }

  void _validateNewPassword() {
    final value = _newPasswordController.text.trim();
    final error = Validations.validateNewPassword(value);

    setState(() {
      if (value == _passwordController.text.trim()) {
        _newPasswordError =
            'La nueva contraseña no puede ser igual a la actual';
      } else if (error != null) {
        _newPasswordError = error;
      } else {
        _newPasswordError = null;
      }
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      _confirmPasswordError = (_confirmPasswordController.text.trim() !=
              _newPasswordController.text.trim())
          ? 'Las contraseñas no coinciden'
          : null;
    });
  }

  bool _validateAll() {
    _validateNewPassword();
    _validateConfirmPassword();

    return _passwordError == null &&
        _newPasswordError == null &&
        _confirmPasswordError == null &&
        _formKey.currentState!.validate();
  }

  Future<void> _updatePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!_validateAll()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Corrige los errores antes de continuar')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _confirmPasswordError = 'Las contraseñas no coinciden');
      return;
    }

    try {
      await _auth.currentUser!.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente')),
      );

      _passwordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _currentUserPasswordCache = null;

      setState(() {
        _passwordError = null;
        _newPasswordError = null;
        _confirmPasswordError = null;
        _currentUserPasswordCache = null;
      });
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'La nueva contraseña es demasiado débil.';
          break;
        case 'requires-recent-login':
          message = 'Debes volver a iniciar sesión.';
          break;
        default:
          message = 'Error: ${e.message}';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // Future<void> _deleteAccount() async {
  //   final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  //   final theme = Theme.of(context);
  //   final confirm = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Confirmar eliminación'),
  //       content: const Text(
  //           '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción es irreversible.'),
  //       actions: [
  //         Row(
  //           children: [
  //             Expanded(
  //               child: TextButton(
  //                 onPressed: () => Navigator.pop(context, false),
  //                 style: ElevatedButton.styleFrom(
  //                   minimumSize: const Size.fromHeight(50),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(14),
  //                     side: BorderSide(
  //                       color: theme.colorScheme.primary,
  //                       width: 2, // Grosor de la línea del borde
  //                     ),
  //                   ),
  //                 ),
  //                 child: Text(
  //                   'Cancelar',
  //                   style: TextStyle(
  //                     color: isDarkMode
  //                         ? theme.colorScheme.onSurface
  //                         : theme.colorScheme.inverseSurface,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 8), // Espacio entre botones
  //             Expanded(
  //               child: ElevatedButton(
  //                 onPressed: () => Navigator.pop(context, true),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: theme.colorScheme.error,
  //                   minimumSize: const Size.fromHeight(50),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(14),
  //                   ),
  //                 ),
  //                 child: Text(
  //                   'Eliminar',
  //                   style: TextStyle(
  //                     color: isDarkMode
  //                         ? theme.colorScheme.onSurface
  //                         : theme.colorScheme.inverseSurface,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         )
  //       ],
  //     ),
  //   );

  //   if (confirm == true) {
  //     try {
  //       final authVM = Provider.of<AuthViewmodel>(context, listen: false);

  //       await authVM
  //           .deleteAccountTotal(); // Aquí debe estar toda la lógica de borrado

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Cuenta eliminada correctamente')),
  //       );
  //       Navigator.of(context).pop();
  //     } on FirebaseAuthException catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error al eliminar cuenta: ${e.message}')),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
        // resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            'Cambio de contraseña',
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
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.35, // tamaño fijo para la imagen
                    child: SvgPicture.asset(
                      isDarkMode
                          ? 'assets/images/change_password2.svg'
                          : 'assets/images/change_password.svg',
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PasswordField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          hintText: 'Contraseña Actual',
                          obscureText: _obscurePassword,
                          onToggle: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          errorText: _passwordError,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        PasswordField(
                          controller: _newPasswordController,
                          hintText: 'Nueva Contraseña',
                          obscureText: _obscureNewPassword,
                          onToggle: () => setState(
                              () => _obscureNewPassword = !_obscureNewPassword),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            final error =
                                Validations.validateNewPassword(value ?? '');
                            if (value == _passwordController.text.trim()) {
                              return 'La nueva contraseña no puede ser igual a la actual';
                            }
                            return error;
                          },
                        ),
                        const SizedBox(height: 16),
                        PasswordField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirmar Nueva Contraseña',
                          obscureText: _obscureConfirmPassword,
                          onToggle: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value != _newPasswordController.text.trim()) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _updatePassword,
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar Cambios'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: isDarkMode
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onInverseSurface,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        // bottomNavigationBar: Padding(
        //   padding: const EdgeInsets.all(16),
        //   child: ElevatedButton.icon(
        //     onPressed: _deleteAccount,
        //     icon: const Icon(Icons.delete_forever),
        //     label: Text(
        //       'Eliminar cuenta',
        //       style: TextStyle(
        //         color: isDarkMode
        //             ? theme.colorScheme.onSurface
        //             : theme.colorScheme.onInverseSurface,
        //       ),
        //     ),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: theme.colorScheme.error,
        //       foregroundColor: isDarkMode
        //           ? theme.colorScheme.onSurface
        //           : theme.colorScheme.onInverseSurface,
        //       minimumSize: const Size.fromHeight(50), // bajé altura a 50
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(14),
        //       ),
        //     ),
        //   ),
        // ),
        );
  }
}
