import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/pay_debt_admin.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/pay_history.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/pay_register.dart';
import 'package:flutter/material.dart';

class AdminPay extends StatefulWidget {
  final int initialIndex;
  final String? cedula;
  final String? nombre;

  const AdminPay({
    super.key,
    this.initialIndex = 0,
    this.cedula,
    this.nombre,
  });

  @override
  State<AdminPay> createState() => _AdminPayState();
}

class _AdminPayState extends State<AdminPay> {
  late int _currentIndex;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    _screens = [
      PayRegister(
        desdeAdmin: false,
        cedula: widget.cedula,
        nombre: widget.nombre,
      ),
      const PayDebtAdmin(),
      const PayHistory(),
    ];
  }

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
