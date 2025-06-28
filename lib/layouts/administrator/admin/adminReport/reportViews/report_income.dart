import 'package:basic_flutter/components/search_bar.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';

final ingresosMock = List.generate(
  10,
  (i) => {
    'fecha': '2025-05-${(i + 10)}',
    'monto': (100 + i * 20).toDouble(),
  },
);

class ReportIncome extends StatefulWidget {
  const ReportIncome({super.key});

  @override
  State<ReportIncome> createState() => _ReportIncomeState();
}

class _ReportIncomeState extends State<ReportIncome> {
  String _selectedPeriodo = 'Mes';
  final List<String> _periodos = ['Día', 'Semana', 'Mes', 'Año'];

  final TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> filteredIngresos = [];

  @override
  void initState() {
    super.initState();
    filteredIngresos = ingresosMock; // Inicialmente mostrar todos
    controller.addListener(_filterIngresos);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _filterIngresos() {
    final query = controller.text.toLowerCase();
    setState(() {
      filteredIngresos = ingresosMock.where((item) {
        final fecha = item['fecha'].toString().toLowerCase();
        final monto = item['monto'].toString().toLowerCase();
        return fecha.contains(query) || monto.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          'Ingresos por periodo',
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Dropdown
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
                          icon: Icon(Icons.calendar_today,
                              color: theme.colorScheme.primary),
                          value: _selectedPeriodo,
                          items: _periodos
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(
                                    p,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedPeriodo = value);
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
                  const SizedBox(width: 12),
                
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.picture_as_pdf,
                        size: 20, color: Colors.redAccent),
                    label: const Text(
                      'PDF',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.redAccent),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Generando PDF de $_selectedPeriodo')),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      foregroundColor: theme.colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.file_copy, size: 20, color: Colors.lightGreen,),
                    label: const Text('Excel',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.lightGreen)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Generando Excel de $_selectedPeriodo')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Aquí el buscador con el controlador
              SearchingBar(controller: controller, theme: theme),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredIngresos.length,
                  itemBuilder: (context, index) {
                    final item = filteredIngresos[index];
                    return Card(
                      elevation: 4,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                      color: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.2),
                          child: Icon(
                            Icons.attach_money,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          item['fecha'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        trailing: Text(
                          '\$${(item['monto'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
