import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/preferences/preferencesView/securityViews/widgets/actions_button.dart';
import 'package:basic_flutter/layouts/preferences/preferencesView/securityViews/widgets/password_file.dart';
import 'package:basic_flutter/layouts/preferences/preferencesView/securityViews/widgets/switch_tile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class PrefSecurity extends StatefulWidget {
  const PrefSecurity({super.key});

  @override
  State<PrefSecurity> createState() => _PrefSecurityState();
}

class _PrefSecurityState extends State<PrefSecurity> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _twoStepAuth = false;
  bool _lockWithPin = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Seguridad',
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
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cambiar Contraseña',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                  hintText: 'Contraseña Actual',
                  obscureText: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _newPasswordController,
                  hintText: 'Nueva Contraseña',
                  obscureText: _obscureNewPassword,
                  onToggle: () => setState(
                      () => _obscureNewPassword = !_obscureNewPassword),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirmar Nueva Contraseña',
                  obscureText: _obscureConfirmPassword,
                  onToggle: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                const SizedBox(height: 24),
                SwitchTile(
                  title: 'Autenticación en dos pasos',
                  value: _twoStepAuth,
                  onChanged: (v) => setState(() => _twoStepAuth = v),
                ),
                SwitchTile(
                  title: 'Bloquear app con PIN / Huella',
                  value: _lockWithPin,
                  onChanged: (v) => setState(() => _lockWithPin = v),
                ),
                const SizedBox(height: 24),
                ActionButton(
                  text: 'Eliminar cuenta',
                  icon: Icons.delete_forever,
                  color: Colors.redAccent,
                  onPressed: () {},
                ),
                const SizedBox(height: 20),
                ActionButton(
                  text: 'Guardar cambios',
                  icon: Icons.save,
                  color: theme.colorScheme.primary,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
