import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:basic_flutter/viewmodel/person_viewmodel.dart';

class TablePersons extends StatefulWidget {
  const TablePersons({super.key});

  @override
  State<TablePersons> createState() => _TablePersonsState();
}

class _TablePersonsState extends State<TablePersons> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final personVM = Provider.of<PersonasViewModel>(context, listen: false);
      personVM.cargarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final personVM = Provider.of<PersonasViewModel>(context);
    final personas = personVM.usuarios;

    return SafeArea(
      child: SingleChildScrollView(
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 25),
                  child: Text(
                    "Lista de personas",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                if (personVM.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (personVM.tipoUsuario == 'Cliente')
                  const Center(
                      child: Text('No tienes acceso a esta información.'))
                else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(color: theme.hintColor),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.onSurface,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? theme.colorScheme.surface
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: isDark
                                ? theme.colorScheme.surface
                                : Colors.grey.shade100,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PaginatedDataTable(
                    columns: [
                      DataColumn(
                          label: Text('Cédula',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600))),
                      DataColumn(
                          label: Text('Nombre',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600))),
                      DataColumn(
                          label: Text('Acciones',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600))),
                    ],
                    source: _DataSource(personas, personVM, theme),
                    rowsPerPage: 5,
                    columnSpacing: 40,
                    dataRowHeight: 60,
                    dividerThickness: 0.5,
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DataSource extends DataTableSource {
  final List<Map<String, dynamic>> _personas;
  final PersonasViewModel viewModel;
  final ThemeData theme;

  _DataSource(this._personas, this.viewModel, this.theme);

  @override
  DataRow getRow(int index) {
    final persona = _personas[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(persona['cedula'] ?? '')),
        DataCell(
            Text('${persona['nombre'] ?? ''} ${persona['apellido'] ?? ''}')),
        DataCell(Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: theme.colorScheme.primary),
              onPressed: () {
                print('Editar ${persona['nombre']}');
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade400),
              onPressed: () {
                // Si tienes eliminarPersona en PersonViewModel
                // _viewModel.eliminarPersona(index);
              },
            ),
          ],
        )),
      ],
    );
  }

  @override
  int get rowCount => _personas.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
