import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/pay_debt_admin.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/pay_history.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/pay_register.dart';
import 'package:flutter/material.dart';

class AdminPay extends StatefulWidget {
  const AdminPay({super.key});

  @override
  State<AdminPay> createState() => _AdminPayState();
}

class _AdminPayState extends State<AdminPay> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PayRegister(
      desdeAdmin: false,
    ),
    const PayDebtAdmin(),
    const PayHistory(),
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
            icon: Icon(Icons.payment_outlined),
            label: 'Registrar',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_membership_outlined),
            label: 'Deudas',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            label: 'Histórico',
          ),
        ],
      ),
    );
  }
}
