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
  Future<void> precargarImagenesAdministrador(BuildContext context) async {
    await Future.wait([
      precacheImage(const AssetImage('assets/images/fondo1.webp'), context),
      precacheImage(const AssetImage('assets/images/fondo2.webp'), context),
      precacheImage(const AssetImage('assets/images/fondo3.webp'), context),
      precacheImage(const AssetImage('assets/images/fondo4.webp'), context),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      Home(nombreUsuario: widget.nombreUsuario, isActive: _currentIndex == 0),
      Administration(isActive: _currentIndex == 1),
      const Preferences(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) async {
          if (index == 1) {
            // Precargar antes de cambiar la pantalla
            await precargarImagenesAdministrador(context);
          }
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
