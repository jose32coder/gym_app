import 'package:basic_flutter/components/search_bar.dart';
import 'package:flutter/material.dart';

// Datos mock para ejemplo
final personasMock = List.generate(15, (i) => 'Persona ${i + 1}');

class ReportTotalperson extends StatefulWidget {
  const ReportTotalperson({super.key});

  @override
  State<ReportTotalperson> createState() => _ReportTotalpersonState();
}

class _ReportTotalpersonState extends State<ReportTotalperson> {
  String _selectedPeriodo = 'Mes';
  final List<String> _periodos = ['Día', 'Semana', 'Mes', 'Año'];
  String _searchText = '';
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        _searchText = controller.text;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Nueva lógica: si no hay texto de búsqueda, muestra todo
    final filteredPersonas = _searchText.isEmpty
        ? personasMock
        : personasMock
            .where((p) => p.toLowerCase().contains(_searchText.toLowerCase()))
            .toList();

    // Debug prints
    print('Texto de búsqueda: $_searchText');
    print('Personas filtradas: $filteredPersonas');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Total de Personas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Fila con dropdown y botones
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
                                    color: theme.colorScheme.primary,
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
                // Botón PDF
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, size: 20),
                  label: const Text('PDF',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Generando PDF de $_selectedPeriodo')),
                    );
                  },
                ),
                const SizedBox(width: 12),
                // Botón Excel
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    backgroundColor: theme.colorScheme.secondary.withAlpha(50),
                    foregroundColor: theme.colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(Icons.file_copy, size: 20),
                  label: const Text('Excel',
                      style: TextStyle(fontWeight: FontWeight.w600)),
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

            // Buscador
            SearchingBar(controller: controller, theme: theme),

            const SizedBox(height: 20),

            // Lista filtrada
            Expanded(
              child: ListView.builder(
                itemCount: filteredPersonas.length,
                itemBuilder: (context, index) {
                  final persona = filteredPersonas[index];
                  return Card(
                    elevation: 4,
                    shadowColor: Colors.teal.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: const Icon(Icons.person, color: Colors.teal),
                      ),
                      title: Text(
                        persona,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
    );
  }
}
