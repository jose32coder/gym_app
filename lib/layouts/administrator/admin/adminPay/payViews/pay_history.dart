import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/viewmodel/pay_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'widgets/payment_card.dart';
import 'widgets/payment_details_modal.dart';
import '../../../../../components/search_bar.dart';

class PayHistory extends StatefulWidget {
  const PayHistory({super.key});

  @override
  _PayHistoryState createState() => _PayHistoryState();
}

class _PayHistoryState extends State<PayHistory> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredPayments = [];
  Map<String, dynamic>? selectedPayment;

  @override
  void initState() {
    super.initState();
    final payVM = context.read<PayViewModel>();
    payVM.cargarGimnasioId(); // Esto carga gimnasioId y pagos automáticamente

    searchController.addListener(_filterPayments);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterPayments() {
    final query = searchController.text.toLowerCase();
    final payments = context.read<PayViewModel>().payments;
    if (!mounted) return; // <-- aquí verificas que el widget siga en árbol
    setState(() {
      filteredPayments = payments.where((payment) {
        final nombreCompleto =
            "${payment['nombre']} ${payment['apellido']}".toLowerCase();
        return nombreCompleto.contains(query);
      }).toList();
    });
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PaymentDetailsModal(
        payment: payment,
        onClose: () {
          Navigator.of(context).pop(); // cerrar el diálogo
        },
      ),
    );
  }

  void _closeModal() {
    setState(() {
      selectedPayment = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final payments = context.watch<PayViewModel>().payments;

    // Inicializar filteredPayments al cargar datos o si está vacío y no hay búsqueda activa
    if (filteredPayments.isEmpty &&
        payments.isNotEmpty &&
        searchController.text.isEmpty) {
      filteredPayments = payments;
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Histórico de pagos',
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.bell),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const NotificationModal(),
                );
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchingBar(
              controller: searchController,
              theme: theme,
            ),
          ),
          Expanded(
            child: filteredPayments.isEmpty
                ? const Center(
                    child: Text('No se encontraron pagos'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
          if (selectedPayment != null)
            PaymentDetailsModal(
              payment: selectedPayment!,
              onClose: _closeModal,
            ),
        ],
      ),
    );
  }
}
