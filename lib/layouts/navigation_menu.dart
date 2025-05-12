import 'package:basic_flutter/layouts/administration.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter/layouts/home.dart';
import 'package:basic_flutter/layouts/add_person.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Home(),
    const AddPersons(showMembresia: true,), // Mostrar Membresía solo en la vista "Agregar"
    const Administration(),
    const Center(child: Text("Lista Personas")),
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
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'Agregar'),
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
