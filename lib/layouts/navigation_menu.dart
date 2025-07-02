import 'package:basic_flutter/layouts/administrator/admin/administration.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferences.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter/layouts/administrator/home/home.dart';

class NavigationMenu extends StatefulWidget {
  final String? nombreUsuario;
  const NavigationMenu({super.key, this.nombreUsuario});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      Home(nombreUsuario: widget.nombreUsuario),
      const Administration(),
      const Preferences(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(
              icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
          NavigationDestination(
              icon: Icon(Icons.settings), label: 'Preferencias'),
        ],
      ),
    );
  }
}
