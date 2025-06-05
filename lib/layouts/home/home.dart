import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/layouts/admin/adminPay/payViews/widgets/history_operations.dart';
import 'package:basic_flutter/layouts/home/widgets/ingresos_chart.dart';
import 'package:basic_flutter/layouts/home/widgets/resume_cards.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/home/widgets/welcome_message.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Panel de control',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bienvenida y fecha
              const WelcomeMessage(),
              Text(
                'Usuarios y actividades',
                style: TextStyles.boldText(context),
              ),
              const SizedBox(
                height: 10,
              ),
              // Resumen rápido (Cards en fila)
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // para que no haga scroll independiente
                children: const [
                  ResumeCards(
                      title: 'Total personas',
                      value: '500',
                      icon: Icons.people,
                      color: Colors.blue),
                  ResumeCards(
                      title: 'Personas activas',
                      value: '320',
                      icon: Icons.person,
                      color: Colors.green),
                  ResumeCards(
                      title: 'Membresías vigentes',
                      value: '280',
                      icon: Icons.card_membership,
                      color: Colors.indigo),
                  ResumeCards(
                      title: 'Por vencer',
                      value: '45',
                      icon: Icons.warning,
                      color: Colors.red),
                ],
              ),
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
              // Planes de Membresía (cards horizontales o GridView)
              const SizedBox(height: 250, child: IngresosChart()),
              // Últimos movimientos (ListView)
              const SizedBox(
                height: 20,
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 5, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Últimos movimientos',
                        style: TextStyles.boldText(context)),
                    const SizedBox(height: 10),
                    const ListaMovimientos(cantidadAMostrar: 5)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
