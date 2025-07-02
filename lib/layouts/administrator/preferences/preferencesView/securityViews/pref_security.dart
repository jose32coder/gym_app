import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/securityViews/subsecurityviews/advanced_security.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/securityViews/subsecurityviews/change_email.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/securityViews/subsecurityviews/change_password.dart';
import 'package:flutter/material.dart';

class PrefSecurity extends StatefulWidget {
  const PrefSecurity({super.key});

  @override
  State<PrefSecurity> createState() => _PrefSecurityState();
}

class _PrefSecurityState extends State<PrefSecurity> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ChangePassword(),
    const ChangeEmail(),
    const AdvancedSecurity()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.lock_reset),
            label: 'Cambiar contraseña',
          ),
          NavigationDestination(
            icon: Icon(Icons.email),
            label: 'Cambiar correo',
          ),
          NavigationDestination(
            icon: Icon(Icons.security),
            label: 'Avanzado',
          ),
        ],
      ),
    );
  }
}
