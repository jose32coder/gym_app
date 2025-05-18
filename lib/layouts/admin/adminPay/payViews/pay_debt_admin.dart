import 'package:basic_flutter/layouts/admin/adminPay/payViews/widgets/filter_date.dart';
import 'package:basic_flutter/layouts/admin/adminPay/payViews/widgets/member_card_state.dart';
import 'package:basic_flutter/layouts/admin/adminPay/payViews/widgets/filter_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class PayDebtAdmin extends StatefulWidget {
  const PayDebtAdmin({super.key});

  @override
  State<PayDebtAdmin> createState() => _PayDebtAdminState();
}

class _PayDebtAdminState extends State<PayDebtAdmin> {
  Future<List<dynamic>>? membresiasFuture;
  String? estadoSeleccionado;
  DateTime? fechaSeleccionada;

  Future<List<dynamic>> cargarMembresias() async {
    String jsonString =
        await rootBundle.loadString('assets/personas_data.json');
    final jsonData = jsonDecode(jsonString);
    return jsonData['membresias'];
  }

  @override
  void initState() {
    super.initState();
    membresiasFuture = cargarMembresias();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: membresiasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar datos'));
        } else {
          final membresias = snapshot.data as List<dynamic>;

          final membresiasFiltradas = membresias.where((m) {
            final estadoCoincide =
                estadoSeleccionado == null || m['estado'] == estadoSeleccionado;
            final fechaCoincide = fechaSeleccionada == null ||
                m['fechaVencimiento'] ==
                    fechaSeleccionada!.toIso8601String().substring(0, 10);
            return estadoCoincide && fechaCoincide;
          }).toList();

          return Column(
            children: [
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  FilterDrop(
                    estadoSeleccionado: estadoSeleccionado,
                    onChanged: (nuevoEstado) {
                      setState(() {
                        estadoSeleccionado = nuevoEstado;
                      });
                    },
                  ),
                  FilterDate(
                    fechaSeleccionada: fechaSeleccionada,
                    onDateSelected: (fecha) {
                      setState(() {
                        fechaSeleccionada = fecha;
                      });
                    },
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        estadoSeleccionado = null;
                        fechaSeleccionada = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar filtros'),
                  ),
                ],
              ),
              Expanded(
                child: membresiasFiltradas.isEmpty
                    ? const Center(child: Text('No hay resultados'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: membresiasFiltradas.length,
                        itemBuilder: (context, index) {
                          final item = membresiasFiltradas[index];
                          return MemberCardState(
                            cliente: item['cliente'],
                            fechaVencimiento: item['fechaVencimiento'],
                            estado: item['estado'],
                            monto: item['monto'].toDouble(),
                          );
                        },
                      ),
              ),
            ],
          );
        }
      },
    );
  }
}
