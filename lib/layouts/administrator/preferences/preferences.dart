import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/createCode/create_code.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/pref_account_and_data.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/pref_notifications.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/securityViews/pref_security.dart';
import 'package:basic_flutter/layouts/administrator/preferences/widgets/preferences_card.dart';
import 'package:basic_flutter/viewmodel/auth_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Preferences extends StatefulWidget {
  const Preferences({super.key});

  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewmodel>(context);
    final userName = authViewModel.userName ?? 'Administrador';
    final userEmail = authViewModel.userEmail ?? 'admin@email.com';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Preferencias',
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: false,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          // Perfil
                          Column(
                            children: [
                              const CircleAvatar(
                                radius: 60,
                                backgroundImage:
                                    AssetImage('assets/images/avatar.png'),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Opciones
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: Column(
                                children: [
                                  PreferenceCard(
                                    icon: Icons.person,
                                    title: 'Cuenta y Datos',
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PrefAccountAndData(),
                                      ),
                                    ),
                                  ),
                                  PreferenceCard(
                                    icon: Icons.notifications,
                                    title: 'Notificaciones',
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PrefNotifications(),
                                      ),
                                    ),
                                  ),
                                  PreferenceCard(
                                    icon: Icons.security,
                                    title: 'Seguridad',
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PrefSecurity(),
                                      ),
                                    ),
                                  ),
                                  PreferenceCard(
                                    icon: Icons.info,
                                    title: 'Crear codigo usuario',
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CreateCode(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Logout
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 24),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  bool? confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmar'),
                                      content: const Text(
                                          '¿Estás seguro que quieres cerrar sesión?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Sí'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    await Future.delayed(const Duration(
                                        seconds: 1)); // simula carga

                                    await FirebaseAuth.instance.signOut();

                                    if (mounted) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  }
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Cerrar sesión'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
