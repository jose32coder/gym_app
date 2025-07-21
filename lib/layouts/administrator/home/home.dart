import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Components
import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';

// Layouts & Widgets
import 'package:basic_flutter/layouts/administrator/admin/adminPer/admin_per.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminReport/widgets/person_details_modal.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/widgets/history_operations.dart';
import 'package:basic_flutter/layouts/administrator/home/widgets/bubble_client.dart';
import 'package:basic_flutter/layouts/administrator/home/widgets/resume_cards.dart';

// ViewModels
import 'package:basic_flutter/viewmodel/pay_viewmodel.dart';
import 'package:basic_flutter/viewmodel/person_viewmodel.dart';

class Home extends StatefulWidget {
  final String? nombreUsuario;
  const Home({super.key, this.nombreUsuario});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      _loadDataOnce(context);
    });
  }

  void _loadDataOnce(BuildContext context) {
    if (_dataLoaded) return;

    final payVM = context.read<PayViewModel>();
    final personasVM = context.read<PersonasViewModel>();

    if (payVM.payments.isEmpty) {
      payVM.cargarGimnasioId();
    }

    if (personasVM.usuarios.isEmpty) {
      personasVM.cargarUsuarios();
    }

    _dataLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final payVM = context.watch<PayViewModel>();
    final personasVM = context.watch<PersonasViewModel>();

    final isLoading = payVM.isLoading || personasVM.isLoading;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
        animation: _controller,
        builder: (context, asyncSnapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Hola, ${widget.nombreUsuario ?? 'Usuario'} 👋',
                style: TextStyles.boldPrimaryText(context),
              ),
              actions: [
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
                      builder: (_) => const NotificationModal(),
                    );
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildUltimosClientes(
                                personasVM, context, isDarkMode),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildResumenUsuarios(personasVM, context),
                        const SizedBox(height: 20),
                        Text('Últimos movimientos',
                            style: TextStyles.boldText(context)),
                        const SizedBox(height: 10),
                        HistoryOperations(payments: payVM.payments),
                      ],
                    ),
                  ),
          );
        });
  }
}

Widget _buildUltimosClientes(
    PersonasViewModel personasVM, BuildContext context, bool isDarkMode) {
  final ultimosClientes = personasVM.ultimosClientes;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Últimos clientes registrados',
              style: TextStyles.boldText(context)),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminPer()),
            ),
            child: const Text('Ver todos'),
          ),
        ],
      ),
      const SizedBox(height: 10),
      if (ultimosClientes.isNotEmpty)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ultimosClientes.map((cliente) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: BubbleClient(
                  cliente: cliente,
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => PersonDetailsModal(
                        persona: cliente,
                        onClose: () => Navigator.of(context).pop(),
                        isDarkMode: isDarkMode,
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        )
      else
        const Text('No hay clientes registrados aún.'),
    ],
  );
}

Widget _buildResumenUsuarios(
    PersonasViewModel personasVM, BuildContext context) {
  final usuarios = personasVM.usuarios;
  final activos = usuarios
      .where((u) => (u['estado'] ?? '').toLowerCase() == 'activo')
      .toList();
  final pendientes = usuarios
      .where((u) => (u['estado'] ?? '').toLowerCase() == 'pendiente')
      .toList();
  final inactivos = usuarios
      .where((u) => (u['estado'] ?? '').toLowerCase() == 'inactivo')
      .toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Estado de usuarios',
        style: TextStyles.boldText(context),
      ),
      const SizedBox(height: 10),
      GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ResumeCards(
              title: 'Total personas',
              value: usuarios.length.toString(),
              icon: Icons.people,
              color: Colors.blue),
          ResumeCards(
              title: 'Activos',
              value: activos.length.toString(),
              icon: Icons.person,
              color: Colors.green),
          ResumeCards(
              title: 'Pendientes',
              value: pendientes.length.toString(),
              icon: Icons.warning,
              color: Colors.yellow),
          ResumeCards(
              title: 'Inactivos',
              value: inactivos.length.toString(),
              icon: Icons.warning,
              color: Colors.red),
        ],
      ),
    ],
  );
}
