import 'package:basic_flutter/components/search_bar.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';

class ReportMembership extends StatefulWidget {
  const ReportMembership({super.key});

  @override
  State<ReportMembership> createState() => _ReportMembershipState();
}

class _ReportMembershipState extends State<ReportMembership>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriodo = 'Mes';
  final List<String> _periodos = ['Día', 'Semana', 'Mes', 'Año'];
  final String _selectedTipo = 'Todas';

  final TextEditingController controller = TextEditingController();

  final List<Map<String, dynamic>> membresiasVigentesMock = [
    {'usuario': 'Juan Pérez', 'tipo': 'Básica', 'vence': '10/08/2025'},
    {'usuario': 'María López', 'tipo': 'Premium', 'vence': '15/08/2025'},
    {'usuario': 'Carlos Ruiz', 'tipo': 'VIP', 'vence': '20/08/2025'},
    {'usuario': 'Ana Gómez', 'tipo': 'Básica', 'vence': '22/08/2025'},
  ];

  final List<Map<String, dynamic>> membresiasMasPagadasMock = [
    {'tipo': 'Premium', 'cantidad': 150},
    {'tipo': 'VIP', 'cantidad': 85},
    {'tipo': 'Básica', 'cantidad': 200},
  ];

  late final List<Map<String, dynamic>> todasMembresias;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    todasMembresias = [
      ...membresiasVigentesMock,
    ];

    _tabController.addListener(() {
      setState(() {});
    });

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    controller.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> filterByTipo(List<Map<String, dynamic>> list) {
    if (_selectedTipo == 'Todas') return list;
    return list.where((m) => m['tipo'] == _selectedTipo).toList();
  }

  List<Map<String, dynamic>> filterBySearch(List<Map<String, dynamic>> list) {
    final query = controller.text.toLowerCase();
    if (query.isEmpty) return list;
    return list.where((m) {
      final usuario = (m['usuario'] ?? '').toString().toLowerCase();
      final tipo = (m['tipo'] ?? '').toString().toLowerCase();
      return usuario.contains(query) || tipo.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget content;

    switch (_tabController.index) {
      case 0:
        var listaFiltrada = filterByTipo(todasMembresias);
        listaFiltrada = filterBySearch(listaFiltrada);
        content = ListView.builder(
          itemCount: listaFiltrada.length,
          itemBuilder: (_, i) {
            final m = listaFiltrada[i];
            return ListTile(
              leading: Icon(Icons.list_alt, color: theme.colorScheme.primary),
              title: Text('${m['tipo']} - ${m['usuario']}'),
              subtitle: Text('Vence: ${m['vence']}'),
            );
          },
        );
        break;

      case 1:
        var listaFiltrada = filterByTipo(membresiasVigentesMock);
        listaFiltrada = filterBySearch(listaFiltrada);
        content = ListView.builder(
          itemCount: listaFiltrada.length,
          itemBuilder: (_, i) {
            final m = listaFiltrada[i];
            return ListTile(
              leading: Icon(Icons.card_membership,
                  color: theme.colorScheme.primary), // ← COLOR AQUÍ
              title: Text('${m['tipo']} - ${m['usuario']}'),
              subtitle: Text('Vence: ${m['vence']}'),
            );
          },
        );
        break;

      case 2:
        var listaFiltrada = _selectedTipo == 'Todas'
            ? membresiasMasPagadasMock
            : membresiasMasPagadasMock
                .where((m) => m['tipo'] == _selectedTipo)
                .toList();
        content = ListView.builder(
          itemCount: listaFiltrada.length,
          itemBuilder: (_, i) {
            final m = listaFiltrada[i];
            return ListTile(
              leading: Icon(Icons.star, color: theme.colorScheme.primary),
              title: Text('${m['tipo']}'),
              trailing: Text('Vendidas: ${m['cantidad']}'),
            );
          },
        );
        break;

      default:
        content = const SizedBox.shrink();
    }

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
          'Membresías',
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.onInverseSurface,
          unselectedLabelColor: isDarkMode
              ? theme.colorScheme.onInverseSurface
              : theme.colorScheme.onSurface,
          labelColor: isDarkMode
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onInverseSurface,
          indicatorSize: TabBarIndicatorSize.tab, // Aquí está la clave
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 3.0,
              color: isDarkMode
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onInverseSurface,
            ),
            insets: EdgeInsets.zero,
          ),
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Vigentes'),
            Tab(text: 'Más pagadas'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
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
                  icon: const Icon(
                    Icons.picture_as_pdf,
                    size: 20,
                    color: Colors.redAccent,
                  ),
                  label: const Text('PDF',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Generando PDF de $_selectedPeriodo')),
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
                  icon: const Icon(
                    Icons.file_copy,
                    size: 20,
                    color: Colors.lightGreen,
                  ),
                  label: const Text('Excel',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.lightGreen)),
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
            SearchingBar(controller: controller, theme: theme),
            const SizedBox(height: 16),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}
