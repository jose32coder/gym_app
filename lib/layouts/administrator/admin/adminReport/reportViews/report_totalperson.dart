import 'dart:io';

import 'package:basic_flutter/components/search_bar.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminReport/widgets/person_details_modal.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminReport/widgets/filter_report.dart';
import 'package:basic_flutter/viewmodel/person_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    // Cargar usuarios al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final personasVM = Provider.of<PersonasViewModel>(context, listen: false);
      personasVM.cargarUsuarios();
    });

    controller.addListener(() {
      setState(() {
        _searchText = controller.text;
      });
    });
  }

  Future<void> generateAndOpenExcel() async {
    final personasVM = Provider.of<PersonasViewModel>(context, listen: false);
    final usuarios = personasVM.usuarios;

    final excel = Excel.createExcel();
    final sheet = excel['ReporteUsuarios'];

    // Encabezados
    final headers = [
      'Nombre Completo',
      'Cédula',
      'Membresía',
      'Habilitado',
      'Estatus',
      'Tipo'
    ];
    sheet.appendRow(headers);

    // Filas de datos
    for (var user in usuarios) {
      final nombreCompleto =
          '${user['nombre'] ?? ''} ${user['apellido'] ?? ''}';
      final cedula = user['cedula'] ?? '';
      final membresia = user['membresia'] ?? 'Sin membresía';
      final habilitado = (user['habilitado'] ?? false) ? 'Sí' : 'No';
      final estatus = user['estatus'] ?? 'Desconocido';
      final tipo = user['tipo'] ?? 'No asignado';

      final row = [
        nombreCompleto,
        cedula,
        membresia,
        habilitado,
        estatus,
        tipo
      ];

      sheet.appendRow(row);
    }

    // Guardado en archivo temporal
    final output = await getTemporaryDirectory();
    final filePath = '${output.path}/reporte_usuarios.xlsx';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      final file = File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      await OpenFile.open(file.path);
    }
  }

  Future<void> generateAndOpenPDF() async {
    final pdf = pw.Document();
    final personasVM = Provider.of<PersonasViewModel>(context, listen: false);

    final usuarios = personasVM.usuarios;

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'Reporte de Usuarios',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'Nombre Completo',
                  'Cédula',
                  'Membresía',
                  'Estatus',
                  'Tipo'
                ],
                data: usuarios.map((user) {
                  final nombreCompleto =
                      '${user['nombre'] ?? ''} ${user['apellido'] ?? ''}';
                  final cedula = user['cedula'] ?? '';
                  final membresia = user['membresia'] ?? 'Sin membresía';
                  final estatus = user['estado'] ?? 'Desconocido';
                  final tipo = user['tipo'] ?? 'No asignado';

                  return [
                    nombreCompleto,
                    cedula,
                    membresia,
                    estatus,
                    tipo,
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
                cellStyle: pw.TextStyle(fontSize: 12),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                headerAlignment: pw.Alignment.center,
                cellAlignment: pw.Alignment.center,
                border:
                    pw.TableBorder.all(width: 0.5, color: PdfColors.grey500),
                columnWidths: {
                  0: pw.FlexColumnWidth(4), // Nombre Completo
                  1: pw.FlexColumnWidth(2), // Cédula
                  2: pw.FlexColumnWidth(3), // Membresía
                  4: pw.FlexColumnWidth(3), // Estatus
                  5: pw.FlexColumnWidth(3), // Tipo
                },
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/reporte_usuarios.pdf');
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final personasVM = Provider.of<PersonasViewModel>(context);

    // Filtrar personas según búsqueda
    final filteredPersonas = _searchText.isEmpty
        ? personasVM.usuarios
        : personasVM.usuarios
            .where((p) =>
                p['nombre'].toLowerCase().contains(_searchText.toLowerCase()) ||
                p['apellido'].toLowerCase().contains(_searchText.toLowerCase()))
            .toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y total
              Text(
                'Total de personas: ${personasVM.usuarios.length}',
                style:
                    TextStyles.boldPrimaryText(context).copyWith(fontSize: 22),
              ),

              const SizedBox(height: 16),

              // Filtros + exportación
              FilterReport(
                periodos: _periodos,
                selectedPeriodo: _selectedPeriodo,
                onPeriodoChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPeriodo = value;
                    });
                  }
                },
                onGeneratePDF: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Generando PDF de todos los usuarios')),
                  );
                  await generateAndOpenPDF();
                },
                onGenerateExcel: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Generando Excel de $_selectedPeriodo')),
                  );
                  await generateAndOpenExcel();
                },
              ),

              const SizedBox(height: 20),

              // Barra de búsqueda
              SearchingBar(controller: controller, theme: theme),

              const SizedBox(height: 20),

              // Estado de carga o lista
              if (personasVM.isLoading)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )
              else if (filteredPersonas.isEmpty)
                Expanded(
                  child: Center(
                    child: Text('No se encontraron personas',
                        style: TextStyles.boldText(context)),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredPersonas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final persona = filteredPersonas[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        shadowColor:
                            theme.colorScheme.primary.withOpacity(0.15),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          leading: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.2),
                            child: Icon(Icons.person,
                                color: theme.colorScheme.primary),
                          ),
                          title: Text(
                            '${persona['nombre']} ${persona['apellido']}',
                            style: TextStyles.boldPrimaryText(context)
                                .copyWith(fontSize: 18),
                          ),
                          subtitle: Text(
                            persona['cedula'] ?? '',
                            style: TextStyle(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onTap: () {
                            final isDarkMode =
                                Theme.of(context).brightness == Brightness.dark;

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => PersonDetailsModal(
                                persona: persona, // el elemento del ListTile
                                onClose: () => Navigator.of(context).pop(),
                                isDarkMode: isDarkMode,
                              ),
                            );
                          },
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
