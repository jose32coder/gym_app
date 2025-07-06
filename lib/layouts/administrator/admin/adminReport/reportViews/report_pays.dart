import 'dart:io';

import 'package:basic_flutter/components/search_bar.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/widgets/payment_details_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminReport/widgets/filter_report.dart';
import 'package:basic_flutter/viewmodel/pay_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportPays extends StatefulWidget {
  const ReportPays({super.key});

  @override
  State<ReportPays> createState() => _ReportPaysState();
}

class _ReportPaysState extends State<ReportPays> {
  String _searchText = '';
  final TextEditingController controller = TextEditingController();
  DateTimeRange? _filtroFecha;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final payVM = Provider.of<PayViewModel>(context, listen: false);
      payVM.fetchPayments();
    });

    controller.addListener(() {
      setState(() {
        _searchText = controller.text;
      });
    });
  }

  Future<void> generateAndOpenExcel() async {
    final payVM = Provider.of<PayViewModel>(context, listen: false);
    final pagos = payVM.payments;

    final excel = Excel.createExcel();
    final sheet = excel['ReportePagos'];

    final headers = [
      'Cliente',
      'Cédula',
      'Membresía',
      'Monto',
      'Fecha',
      'Estado'
    ];
    sheet.appendRow(headers);

    for (var pago in pagos) {
      final cliente = '${pago['nombre'] ?? ''} ${pago['apellido'] ?? ''}';
      final cedula = pago['cedula'] ?? '';
      final membresia = pago['membresia'] ?? 'Sin membresía';
      final monto = pago['monto']?.toString() ?? '0';
      final fecha = pago['fechaPago'] != null
          ? (pago['fechaPago'] as Timestamp).toDate().toString()
          : 'Sin fecha';
      final estado = pago['estado'] ?? 'Desconocido';

      final row = [cliente, cedula, membresia, monto, fecha, estado];
      sheet.appendRow(row);
    }

    final output = await getTemporaryDirectory();
    final filePath = '${output.path}/reporte_pagos.xlsx';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      final file = File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      await OpenFile.open(file.path);
    }
  }

  Future<void> generateAndOpenPDF(
      List<Map<String, dynamic>> pagosFiltrados) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'Reporte de Pagos',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'Cliente',
                  'Cédula',
                  'Membresía',
                  'Monto',
                  'Fecha',
                  'Estado'
                ],
                data: pagosFiltrados.map((pago) {
                  final cliente =
                      '${pago['nombre'] ?? ''} ${pago['apellido'] ?? ''}';
                  final cedula = pago['cedula'] ?? '';
                  final membresia = pago['membresia'] ?? 'Sin membresía';
                  final monto = pago['monto']?.toString() ?? '0';
                  final fecha = pago['fechaPago'] != null
                      ? (pago['fechaPago'] as Timestamp).toDate().toString()
                      : 'Sin fecha';
                  final estado = pago['estado'] ?? 'Desconocido';

                  return [cliente, cedula, membresia, monto, fecha, estado];
                }).toList(),
                headerStyle:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                cellStyle: const pw.TextStyle(fontSize: 12),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                headerAlignment: pw.Alignment.center,
                cellAlignment: pw.Alignment.center,
                border:
                    pw.TableBorder.all(width: 0.5, color: PdfColors.grey500),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(3),
                  5: const pw.FlexColumnWidth(2),
                },
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/reporte_pagos.pdf');
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
    final payVM = Provider.of<PayViewModel>(context);

    final filteredPagos = payVM.payments.where((p) {
      final cliente = '${p['nombre']} ${p['apellido']}'.toLowerCase();
      final coincideTexto = _searchText.isEmpty
          ? true
          : cliente.contains(_searchText.toLowerCase());

      bool coincideFecha = true;
      if (_filtroFecha != null && p['fechaPago'] != null) {
        final timestamp = p['fechaPago'] as Timestamp;
        final fechaPago = timestamp.toDate();

        coincideFecha = fechaPago.isAfter(
                _filtroFecha!.start.subtract(const Duration(seconds: 1))) &&
            fechaPago
                .isBefore(_filtroFecha!.end.add(const Duration(seconds: 1)));
      }
      return coincideTexto && coincideFecha;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pagos totales: ${payVM.payments.length}',
                style: TextStyles.boldText(context).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 14),
              FilterReport(
                onGeneratePDF: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Generando PDF de todos los pagos')),
                  );
                  await generateAndOpenPDF(filteredPagos);
                },
                onGenerateExcel: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generando Excel')),
                  );
                  await generateAndOpenExcel();
                },
                onDateRangeChanged: (dateRange) {
                  setState(() {
                    _filtroFecha = dateRange;
                  });
                },
              ),
              const SizedBox(height: 14),
              SearchingBar(controller: controller, theme: theme),
              const SizedBox(height: 20),
              if (payVM.isLoading)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )
              else if (filteredPagos.isEmpty)
                Expanded(
                  child: Center(
                    child: Text('No se encontraron pagos',
                        style: TextStyles.boldText(context)),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredPagos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final pago = filteredPagos[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        shadowColor:
                            theme.colorScheme.primary.withOpacity(0.15),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.15),
                            child: Icon(
                              Icons.attach_money,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            '${pago['nombre'] ?? 'Sin nombre'}',
                            style: TextStyles.boldText(context)
                                .copyWith(fontSize: 17),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Monto: ${pago['monto'] ?? 0} \$',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.75),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              if (pago['nombreMembresia'] != null)
                                Text(
                                  'Membresía: ${pago['nombreMembresia']}',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: theme.colorScheme.primary.withOpacity(0.7),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => PaymentDetailsModal(
                                payment: pago,
                                onClose: () => Navigator.of(context).pop(),
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
