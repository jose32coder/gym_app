import 'package:basic_flutter/layouts/admin/adminPay/payViews/widgets/member_card_state.dart';
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
    return FutureBuilder<List<dynamic>>(
      future: membresiasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar datos'));
        } else {
          final membresias = snapshot.data ?? [];

          final membresiasFiltradas = membresias.where((m) {
            final estadoCoincide =
                estadoSeleccionado == null || m['estado'] == estadoSeleccionado;
            return estadoCoincide;
          }).toList();

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: FilterDrop(
                  estadoSeleccionado: estadoSeleccionado,
                  onChanged: (nuevoEstado) {
                    setState(() {
                      estadoSeleccionado = nuevoEstado;
                    });
                  },
                ),
              ),

              // Separación entre filtro y lista
              const SizedBox(height: 12),

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
                            monto: (item['monto'] as num).toDouble(),
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

class FilterDrop extends StatelessWidget {
  final String? estadoSeleccionado;
  final ValueChanged<String?> onChanged;

  const FilterDrop({
    super.key,
    required this.estadoSeleccionado,
    required this.onChanged,
  });

  static const List<String> estados = [
    'Por Vencer',
    'Vencido',
    'Activo',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Valor para "Todos"
    const todosValor = 'todos';

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                icon: Icon(Icons.filter_list, color: theme.colorScheme.primary),
                value: estadoSeleccionado ?? todosValor,
                items: [
                  const DropdownMenuItem<String>(
                    value: todosValor,
                    child: Text('Todos'),
                  ),
                  ...estados.map(
                    (estado) => DropdownMenuItem<String>(
                      value: estado,
                      child: Text(
                        estado,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == todosValor) {
                    onChanged(null);
                  } else {
                    onChanged(value);
                  }
                },
                dropdownColor: theme.cardColor,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
