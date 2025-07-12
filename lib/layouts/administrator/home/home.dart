import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:basic_flutter/layouts/administrator/home/widgets/ingresos_chart.dart';
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

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();

    // Cargar gimnasioId y pagos al iniciar
    final payVM = context.read<PayViewModel>();
    payVM.cargarGimnasioId();

    // Cargar usuarios después de que el widget se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final personasVM = context.read<PersonasViewModel>();
      personasVM.cargarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final payments = context.watch<PayViewModel>().payments;

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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const NotificationModal(),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Consumer<PayViewModel>(
        builder: (context, payVM, _) {
          if (payVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección: Últimos clientes
                  Consumer<PersonasViewModel>(
                    builder: (context, personasVM, _) {
                      final ultimosClientes = personasVM.ultimosClientes;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Últimos clientes registrados',
                                style: TextStyles.boldText(context),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminPer(),
                                  ),
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
                                            onClose: () =>
                                                Navigator.of(context).pop(),
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
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),

                  // Sección: Resumen de usuarios y actividades
                  Text(
                    'Usuarios y actividades',
                    style: TextStyles.boldText(context),
                  ),
                  const SizedBox(height: 10),
                  Consumer<PersonasViewModel>(
                    builder: (context, personasVM, _) {
                      final usuarios = personasVM.usuarios;
                      final activos = usuarios
                          .where((u) =>
                              (u['estado'] ?? '').toString().toLowerCase() ==
                              'activo')
                          .toList();
                      final inactivos = usuarios
                          .where((u) =>
                              (u['estado'] ?? '').toString().toLowerCase() ==
                              'inactivo')
                          .toList();

                      return GridView.count(
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
                            color: Colors.blue,
                          ),
                          ResumeCards(
                            title: 'Personas activas',
                            value: activos.length.toString(),
                            icon: Icons.person,
                            color: Colors.green,
                          ),
                          ResumeCards(
                            title: 'Inactivos',
                            value: inactivos.length.toString(),
                            icon: Icons.person_off,
                            color: Colors.yellow,
                          ),
                          const ResumeCards(
                            title: 'Por vencer',
                            value: '45',
                            icon: Icons.warning,
                            color: Colors.red,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Sección: Promedio de ingresos
                  Text(
                    'Promedio de ingresos',
                    style: TextStyles.boldText(context),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 250, child: IngresosChart()),
                  const SizedBox(height: 20),

                  // Sección: Últimos movimientos
                  Text(
                    'Últimos movimientos',
                    style: TextStyles.boldText(context),
                  ),
                  const SizedBox(height: 10),
                  HistoryOperations(payments: payments),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
