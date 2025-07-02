import 'package:basic_flutter/layouts/administrator/persons/add_person.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:basic_flutter/viewmodel/person_viewmodel.dart';

class TablePersons extends StatefulWidget {
  const TablePersons({super.key});

  @override
  State<TablePersons> createState() => _TablePersonsState();
}

class _TablePersonsState extends State<TablePersons> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final personVM = Provider.of<PersonasViewModel>(context, listen: false);
      personVM.cargarUsuarios();
    });

    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final personVM = Provider.of<PersonasViewModel>(context);
    final personas = personVM.usuarios;

    final filteredPersonas = personas.where((persona) {
      final cedula = (persona['cedula'] ?? '').toLowerCase();
      final nombre = (persona['nombre'] ?? '').toLowerCase();
      return cedula.contains(_searchTerm) || nombre.contains(_searchTerm);
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 25, right: 25),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lista de personas",
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              "totales",
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddPersons(),
                                ),
                              );
                              // Esto se ejecuta cuando regresas de AddPersons
                              final personVM = Provider.of<PersonasViewModel>(
                                  context,
                                  listen: false);
                              personVM.cargarUsuarios();
                            },
                            icon: Icon(
                              Icons.add,
                              color: isDarkMode
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onInverseSurface,
                            ),
                            label: Text(
                              'Agregar',
                              style: TextStyle(
                                color: isDarkMode
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onInverseSurface,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(color: theme.hintColor),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.onSurface,
                        ),
                        filled: true,
                        fillColor: isDarkMode
                            ? theme.colorScheme.onInverseSurface
                            : theme.colorScheme.onInverseSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onInverseSurface,
                          ),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {}); // Actualiza al escribir
                      },
                    ),
                  ],
                ),
              ),
              if (personVM.isLoading)
                SizedBox(
                  height: MediaQuery.of(context).size.height /
                      2, // ocupa toda la altura
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Builder(builder: (context) {
                  final filteredPersonas = personas.where((persona) {
                    final cedula = (persona['cedula'] ?? '').toLowerCase();
                    final nombre = (persona['nombre'] ?? '').toLowerCase();
                    final search = _searchController.text.trim().toLowerCase();
                    return cedula.contains(search) || nombre.contains(search);
                  }).toList();

                  if (filteredPersonas.isEmpty) {
                    return Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 2,
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                'No hay datos para mostrar.',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      PaginatedDataTable(
                        columns: [
                          DataColumn(
                            label: Text('Cédula',
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600)),
                          ),
                          DataColumn(
                            label: Text('Nombre',
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600)),
                          ),
                          DataColumn(
                            label: Text('Acciones',
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                        source: _DataSource(filteredPersonas, personVM, theme),
                        rowsPerPage: 7,
                        columnSpacing: 30,
                        dataRowHeight: 55,
                        dividerThickness: 0.5,
                      ),
                    ],
                  );
                }),
            ]),
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

    String nombreCompleto = persona['nombre'] ?? '';
    String apellidoCompleto = persona['apellido'] ?? '';

    String primerNombre = nombreCompleto.split(' ').first;
    String primerApellido = apellidoCompleto.split(' ').first;

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(persona['cedula'] ?? '')),
        DataCell(Text('$primerNombre $primerApellido')),
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
