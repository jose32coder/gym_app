import 'package:basic_flutter/layouts/admin/administration.dart';
import 'package:basic_flutter/layouts/preferences/preferences.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter/layouts/home/home.dart';
import 'package:basic_flutter/layouts/persons/add_person.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Home(),
    const Administration(),
    const Preferences(),
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
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(
              icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
          NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Preferencias'),
        ],
      ),
    );
  }
}
