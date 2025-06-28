import 'package:basic_flutter/layouts/administrator/admin/adminMemberAndPromos/adminMember/admin_member.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminMemberAndPromos/adminPromos/admin_promos.dart';
import 'package:flutter/material.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminMember(),
    const AdminPromos(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.card_membership_outlined),
            label: 'Membresías',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            label: 'Promociones',
          ),
        ],
      ),
    );
  }
}
