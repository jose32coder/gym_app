import 'package:basic_flutter/layouts/admin/adminPay/payViews/widgets/history_operations.dart';
import 'package:basic_flutter/layouts/home/widgets/ingresos_chart.dart';
import 'package:basic_flutter/layouts/home/widgets/resume_cards.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/home/widgets/welcome_message.dart';
import 'package:flutter/material.dart';

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
          style: TextStyles.boldText(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.add_alert),
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
              SizedBox(
                height: 10,
              ),
              // Resumen rápido (Cards en fila)
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                shrinkWrap: true,
                physics:
                    NeverScrollableScrollPhysics(), // para que no haga scroll independiente
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
              SizedBox(
                height: 20,
              ),
              Text(
                'Promedio de ingresos',
                style: TextStyles.boldText(context),
              ),
              SizedBox(
                height: 10,
              ),
              // Planes de Membresía (cards horizontales o GridView)
              SizedBox(height: 250, child: IngresosChart()),
              // Últimos movimientos (ListView)
              SizedBox(
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
