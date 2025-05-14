import 'package:flutter/material.dart';

class TablaPersonas extends StatelessWidget {
  const TablaPersonas({super.key});

  // Datos de ejemplo
  final List<Map<String, String>> personas = const [
    {
      "cedula": "V-12345678",
      "nombre": "Carlos",
      "apellido": "Pérez",
      "direccion": "Calle Falsa 123",
      "acciones": "Editar | Eliminar"
    },
    {
      "cedula": "V-87654321",
      "nombre": "Ana",
      "apellido": "Gómez",
      "direccion": "Avenida Siempre Viva 742",
      "acciones": "Editar | Eliminar"
    },
    {
      "cedula": "V-23456789",
      "nombre": "Luis",
      "apellido": "Mendoza",
      "direccion": "Calle 9, Edificio A",
      "acciones": "Editar | Eliminar"
    },
    {
      "cedula": "V-24681357",
      "nombre": "Luisa",
      "apellido": "Martínez",
      "direccion": "Plaza Central, Local 4",
      "acciones": "Editar | Eliminar"
    },
    {
      "cedula": "V-11223344",
      "nombre": "Pedro",
      "apellido": "López",
      "direccion": "Calle 5, Casa 10",
      "acciones": "Editar | Eliminar"
    },
    {
      "cedula": "V-44332211",
      "nombre": "María",
      "apellido": "Hernández",
      "direccion": "Boulevard Norte, Apt. 2",
      "acciones": "Editar | Eliminar"
    },
    {
      "cedula": "V-66778899",
      "nombre": "Sofía",
      "apellido": "Vargas",
      "direccion": "Calle 12, 3° piso",
      "acciones": "Editar | Eliminar"
    },
    {
      "cedula": "V-99887766",
      "nombre": "Lucas",
      "apellido": "Morales",
      "direccion": "Calle 3, Piso 1",
      "acciones": "Editar | Eliminar"
    },
    {
      "cedula": "V-55443322",
      "nombre": "Paula",
      "apellido": "Díaz",
      "direccion": "Avenida 5, Edificio B",
      "acciones": "Editar | Eliminar"
    },
    {
      "cedula": "V-22334455",
      "nombre": "Javier",
      "apellido": "Luna",
      "direccion": "Calle 7, Local 9",
      "acciones": "Editar | Eliminar"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 25),
                  child: Text(
                    "Lista de Personas",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      hintStyle: TextStyle(color: theme.hintColor),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.colorScheme.primary,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? theme.colorScheme.surface
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color:  isDark
                          ? theme.colorScheme.surface
                          : Colors.grey.shade100,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                PaginatedDataTable(
                  columns: [
                    DataColumn(
                        label: Text('Cédula',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600))),
                    DataColumn(
                        label: Text('Nombre',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600))),
                    DataColumn(
                        label: Text('Dirección',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600))),
                    DataColumn(
                        label: Text('Acciones',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600))),
                  ],
                  source: _DataSource(personas, theme),
                  rowsPerPage: 5,
                  columnSpacing: 40,
                  dataRowHeight: 60,
                  dividerThickness: 0.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DataSource extends DataTableSource {
  final List<Map<String, String>> _personas;
  final ThemeData theme;

  _DataSource(this._personas, this.theme);

  @override
  DataRow getRow(int index) {
    final persona = _personas[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(persona['cedula']!)),
        DataCell(Text('${persona['nombre']} ${persona['apellido']}')),
        DataCell(Text(persona['direccion']!)),
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
                print('Eliminar ${persona['nombre']}');
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
