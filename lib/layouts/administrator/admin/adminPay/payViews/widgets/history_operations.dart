import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/widgets/payment_card.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/widgets/payment_details_modal.dart';
import 'package:flutter/material.dart';

class HistoryOperations extends StatelessWidget {
  final List<Map<String, dynamic>> payments;

  const HistoryOperations({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    final lastFivePayments =
        payments.length > 5 ? payments.sublist(payments.length - 5) : payments;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lastFivePayments.length,
      itemBuilder: (context, index) {
        final payment = lastFivePayments[index];
        return PaymentCard(
          payment: payment,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => PaymentDetailsModal(
                payment: payment,
                onClose: () => Navigator.of(context).pop(),
              ),
            );
          },
        );
      },
    );
  }
}
