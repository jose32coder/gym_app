import 'package:flutter/material.dart';
import 'widgets/payment_card.dart';
import 'widgets/payment_details_modal.dart';
import 'widgets/search_bar.dart';

class PayHistory extends StatefulWidget {
  @override
  _PayHistoryState createState() => _PayHistoryState();
}

class _PayHistoryState extends State<PayHistory> {
  final List<Map<String, dynamic>> allPayments = [
    {
      'nombre': 'Juan Perez',
      'monto': 150.00,
      'fecha': DateTime(2025, 5, 17),
      'tipoPago': 'Bolívares (Bs)',
      'referencia': 'REF12345',
    },
    {
      'nombre': 'Maria Gomez',
      'monto': 200.00,
      'fecha': DateTime(2025, 5, 15),
      'tipoPago': 'Dólares (\$)',
      'referencia': null,
    },
    {
      'nombre': 'Carlos Ruiz',
      'monto': 350.50,
      'fecha': DateTime(2025, 5, 10),
      'tipoPago': 'Ambos',
      'referencia': 'REF98765',
    },
    {
      'nombre': 'Ana Torres',
      'monto': 400.00,
      'fecha': DateTime(2025, 5, 9),
      'tipoPago': 'Bolívares (Bs)',
      'referencia': 'REF65432',
    },
  ];

  List<Map<String, dynamic>> filteredPayments = [];
  Map<String, dynamic>? selectedPayment;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredPayments = allPayments;
    searchController.addListener(_filterPayments);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterPayments() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredPayments = allPayments.where((payment) {
        final nombre = payment['nombre'].toLowerCase();
        return nombre.contains(query);
      }).toList();
    });
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    setState(() {
      selectedPayment = payment;
    });
  }

  void _closeModal() {
    setState(() {
      selectedPayment = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Column(
          children: [
            SearchingBar(
              controller: searchController,
              theme: theme,
            ),
            Expanded(
              child: filteredPayments.isEmpty
                  ? Center(
                      child: Text(
                        'No se encontraron pagos',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredPayments.length,
                      itemBuilder: (context, index) {
                        final payment = filteredPayments[index];
                        return PaymentCard(
                          payment: payment,
                          onTap: () => _showPaymentDetails(payment),
                        );
                      },
                    ),
            ),
          ],
        ),
        if (selectedPayment != null)
          PaymentDetailsModal(
            payment: selectedPayment!,
            onClose: _closeModal,
          ),
      ],
    );
  }
}
