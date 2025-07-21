import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/widgets/payment_details_estate_modal.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/widgets/payment_details_modal.dart';
import 'package:basic_flutter/viewmodel/person_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'widgets/payment_state_card.dart';
import '../../../../../components/search_bar.dart';

class PayDebtAdmin extends StatefulWidget {
  const PayDebtAdmin({super.key});

  @override
  _PayDebtAdminState createState() => _PayDebtAdminState();
}

class _PayDebtAdminState extends State<PayDebtAdmin> {
  TextEditingController searchController = TextEditingController();
  Map<String, dynamic>? pagoSeleccionado;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final personasVM = context.read<PersonasViewModel>();
      if (!personasVM.isLoading && personasVM.usuarios.isEmpty) {
        personasVM.cargarUsuariosSiNecesario();
      }
    });

    searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtrarUsuarios(
      List<Map<String, dynamic>> usuarios) {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) return usuarios;

    return usuarios.where((payment) {
      final nombre = payment['Cliente']?.toLowerCase() ?? '';
      return nombre.contains(query);
    }).toList();
  }

  Future<void> _recargarDatos() async {
    await context.read<PersonasViewModel>().recargarUsuarios();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos de estado clientes actualizados')),
    );
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    setState(() {
      pagoSeleccionado = payment;
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ClienteDetailsModal(
          cliente: payment,
          onClose: () {
            Navigator.of(context).pop();
            setState(() {
              pagoSeleccionado = null;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final personasVM = context.watch<PersonasViewModel>();

    final usuariosFiltrados = _filtrarUsuarios(personasVM.usuarios);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Estado de cliente',
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.rotateRight),
                  onPressed: personasVM.isLoading ? null : _recargarDatos,
                ),
                IconButton(
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
              ],
            ),
          )
        ],
      ),
      body: personasVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SearchingBar(
                    controller: searchController,
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: usuariosFiltrados.length,
                    itemBuilder: (context, index) {
                      final item = usuariosFiltrados[index];
                      return GestureDetector(
                        onTap: () => _showPaymentDetails(item),
                        child: PaymentStateCard(
                          cliente: item,
                          estado: item['estado'] ?? 'Desconocido',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
