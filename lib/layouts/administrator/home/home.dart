import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/widgets/history_operations.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPer/admin_per.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminReport/widgets/person_details_modal.dart';
import 'package:basic_flutter/layouts/administrator/home/widgets/bubble_client.dart';
import 'package:basic_flutter/layouts/administrator/home/widgets/ingresos_chart.dart';
import 'package:basic_flutter/layouts/administrator/home/widgets/resume_cards.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/viewmodel/person_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final personasVM = Provider.of<PersonasViewModel>(context, listen: false);
      personasVM.cargarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hola, ${widget.nombreUsuario != null ? '${widget.nombreUsuario} 👋' : 'Usuario'}',
          style: TextStyles.boldPrimaryText(context),
        ),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- NUEVO: Burbuja últimos clientes ---
            Consumer<PersonasViewModel>(
              builder: (context, personasVM, _) {
                final ultimosClientes = personasVM.ultimosClientes;

                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título arriba
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
                                    builder: (context) => const AdminPer())),
                            child: const Text('Ver todos'),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Row con las burbujas horizontalmente
                      if (ultimosClientes.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ultimosClientes
                                .map(
                                  (cliente) => Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: BubbleClient(
                                      cliente: cliente,
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) =>
                                              PersonDetailsModal(
                                            persona: cliente,
                                            onClose: () =>
                                                Navigator.of(context).pop(),
                                            isDarkMode:
                                                isDarkMode, // tu variable de modo oscuro
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        )
                      else
                        const Text('No hay clientes registrados aún.'),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),

            // Título existente "Usuarios y actividades"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usuarios y actividades',
                    style: TextStyles.boldText(context),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // Resumen rápido (Cards en fila)
                  Consumer<PersonasViewModel>(
                    builder: (context, personasVM, _) {
                      final usuarios = personasVM.usuarios;
                      final activos = usuarios.where((u) {
                        final estado =
                            (u['estado'] ?? '').toString().toLowerCase();
                        return estado == 'activo';
                      }).toList();
                      final inactivos = usuarios.where((u) {
                        final estado =
                            (u['estado'] ?? '').toString().toLowerCase();
                        return estado == 'inactivo';
                      }).toList();

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
                            title: 'Membresías vigentes',
                            value: inactivos.length.toString(),
                            icon: Icons.person,
                            color: Colors.yellow,
                          ),
                          ResumeCards(
                            title: 'Por vencer',
                            value: '45',
                            icon: Icons.warning,
                            color: Colors.red,
                          ),
                        ],
                      );
                    },
                  ),

                  // Resto de tu código sin cambios...
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Promedio de ingresos',
                    style: TextStyles.boldText(context),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(height: 250, child: IngresosChart()),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Últimos movimientos',
                          style: TextStyles.boldText(context)),
                      const SizedBox(height: 10),
                      ListaMovimientos(cantidadAMostrar: 5),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
