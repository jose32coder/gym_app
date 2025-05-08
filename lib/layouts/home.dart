import 'package:basic_flutter/components/history_operations.dart';
import 'package:basic_flutter/components/plan_membership.dart';
import 'package:basic_flutter/components/resume_cards.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/components/welcome_message.dart';
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
        title: const Text(
          'Panel de control',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.add_alert),
          )
        ],
      ),
      body:  SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Bienvenida y fecha
              const WelcomeMessage(),
              // Resumen rápido (Cards en fila)
              const ResumeCards(),
              // Planes de Membresía (cards horizontales o GridView)
              const PlanMembership(),
              // Últimos movimientos (ListView)

              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 5, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Últimos Movimientos', style: TextStyles.boldText(context)),
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
