import 'package:basic_flutter/layouts/admin/adminPay/widgets/admin_card_pay_grid.dart';

import 'package:flutter/material.dart';

class AdminPay extends StatefulWidget {
  const AdminPay({super.key});

  @override
  State<AdminPay> createState() => _AdminPayState();
}

class _AdminPayState extends State<AdminPay> {
  Widget? selectedView;

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).primaryColor;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pagos / Facturación'),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.add_alert),
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Administra los pagos:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildAdminCards(),
                ],
              ),
            ),
            SizedBox(height: 10),
            if (selectedView != null) ...[
              Divider(
                thickness: 3,
                color: mainColor,
              ),
              SizedBox(height: 2),
              Expanded(child: selectedView!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCards() {
    return AdminCardPayGrid(
      onCardSelected: (Widget selected) {
        setState(() {
          selectedView = selected;
        });
      },
    );
  }
}
