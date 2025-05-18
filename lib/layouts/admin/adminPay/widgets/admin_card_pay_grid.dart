import 'package:basic_flutter/layouts/admin/adminPay/payViews/pay_history.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter/layouts/admin/adminPay/widgets/admin_pay_cards.dart';
import 'package:basic_flutter/layouts/admin/adminPay/payViews/pay_debt_admin.dart';
import 'package:basic_flutter/layouts/admin/adminPay/payViews/pay_register.dart';

class AdminCardPayGrid extends StatelessWidget {
  final Function(Widget) onCardSelected;

  const AdminCardPayGrid({super.key, required this.onCardSelected});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1 / 1, // más ancho y menos alto
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        AdminPayCard(
          onTap: () => onCardSelected(PayRegister(desdeAdmin: true)),
          icon: Icons.payment,
          label: 'Registrar pago',
          color: Colors.blue,
          onCardSelected: (Widget selected) {},
        ),
        AdminPayCard(
          onTap: () => onCardSelected(const PayDebtAdmin()),
          icon: Icons.receipt_long,
          label: 'Pagos y deudas',
          color: Colors.orange,
          onCardSelected: (Widget selected) {},
        ),
        AdminPayCard(
          onTap: () => onCardSelected(PayHistory()),
          icon: Icons.receipt_long,
          label: 'Historico de pagos',
          color: Colors.green,
          onCardSelected: (Widget selected) {},
        ),
      ],
    );
  }
}
