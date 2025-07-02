// import 'package:basic_flutter/components/text_style.dart';
// import 'package:basic_flutter/components/validations.dart';
// import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/securityViews/subsecurityviews/widgets/email_file.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class ChangeEmail extends StatefulWidget {
//   const ChangeEmail({super.key});

//   @override
//   State<ChangeEmail> createState() => _ChangeEmailState();
// }

// class _ChangeEmailState extends State<ChangeEmail> {
//   final _formKey = GlobalKey<FormState>();

//   final _newEmailController = TextEditingController();
//   final _emailActuallyController = TextEditingController();
//   final _emailFocusNode = FocusNode();
//   final _newEmailFocusNode = FocusNode();
//   final _passwordController = TextEditingController();

//   final _auth = FirebaseAuth.instance;

//   @override
//   void dispose() {
//     _newEmailController.dispose();
//     _emailFocusNode.dispose();
//     _newEmailFocusNode.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     final user = _auth.currentUser;
//     _emailActuallyController.text = user?.email ?? '';
//   }

//   Future<void> _showPasswordModal() async {
//     final theme = Theme.of(context);
//     _passwordController.clear();

//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Confirmar contraseña'),
//           content: TextField(
//             controller: _passwordController,
//             obscureText: true,
//             decoration: InputDecoration(
//               labelText: 'Contraseña actual',
//               border: OutlineInputBorder(),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: theme.colorScheme.primary),
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('Cancelar'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: theme.colorScheme.primary,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Confirmar'),
//             ),
//           ],
//         );
//       },
//     );

//     if (result == true) {
//       _changeEmailWithPassword(_passwordController.text.trim());
//     }
//   }

//   Future<void> _changeEmailWithPassword(String password) async {
//     final user = _auth.currentUser;
//     print('Proveedores del usuario actual:');
//     user?.providerData.forEach((provider) {
//       print(provider.providerId);
//     });
//     final newEmail = _newEmailController.text.trim();

//     if (user == null) return;

//     final hasPasswordProvider =
//         user.providerData.any((p) => p.providerId == 'password');

//     if (!hasPasswordProvider) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('No se puede cambiar el correo usando contraseña.')),
//       );
//       return;
//     }

//     try {
//       final credential = EmailAuthProvider.credential(
//         email: user.email!,
//         password: password,
//       );

//       await user.reauthenticateWithCredential(credential);
//       await user.updateEmail(newEmail);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Correo actualizado correctamente')),
//       );

//       _newEmailController.clear();
//       FocusScope.of(context).unfocus();
//     } on FirebaseAuthException catch (e) {
//       String message;
//       switch (e.code) {
//         case 'wrong-password':
//           message = 'Contraseña incorrecta.';
//           break;
//         case 'email-already-in-use':
//           message = 'El correo ya está en uso.';
//           break;
//         case 'requires-recent-login':
//           message = 'Por seguridad, vuelve a iniciar sesión.';
//           break;
//         default:
//           message = 'Error al actualizar el correo: ${e.message}';
//           break;
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = _auth.currentUser;
//     final theme = Theme.of(context);
//     bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Cambio de correo'),
//         centerTitle: true,
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.40,
//                   child: Center(
//                     child: SvgPicture.asset(
//                       isDarkMode
//                           ? 'assets/images/email_change2.svg'
//                           : 'assets/images/email_change.svg',
//                       width: double.infinity,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Correo actual',
//                         style: TextStyles.boldText(context),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 12, horizontal: 16),
//                         decoration: BoxDecoration(
//                           color: isDarkMode
//                               ? Colors.grey.shade800
//                               : Colors.grey.shade200,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           user?.email ?? 'No disponible',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: isDarkMode ? Colors.white70 : Colors.black87,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: _newEmailController,
//                         focusNode: _newEmailFocusNode,
//                         autovalidateMode: AutovalidateMode.onUserInteraction,
//                         validator: (value) {
//                           final validation = Validations.validateEmail(value);
//                           if (validation != null) return validation;
//                           if (value == user?.email)
//                             return 'El nuevo correo debe ser diferente';
//                           return null;
//                         },
//                         style: TextStyle(
//                             color: isDarkMode ? Colors.white : Colors.black87),
//                         decoration: InputDecoration(
//                           hintText: 'Nuevo correo',
//                           prefixIcon: const Icon(Icons.email),
//                           filled: true,
//                           fillColor:
//                               isDarkMode ? Colors.grey.shade800 : Colors.white,
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton.icon(
//                           onPressed: () {
//                             if (_formKey.currentState?.validate() ?? false) {
//                               _showPasswordModal();
//                             }
//                           },
//                           icon: const Icon(Icons.save),
//                           label: const Text('Guardar Cambios'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: theme.colorScheme.primary,
//                             foregroundColor: isDarkMode
//                                 ? theme.colorScheme.onSurface
//                                 : theme.colorScheme.onInverseSurface,
//                             minimumSize: const Size.fromHeight(50),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ChangeEmail extends StatelessWidget {
  const ChangeEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Próximamente...',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
