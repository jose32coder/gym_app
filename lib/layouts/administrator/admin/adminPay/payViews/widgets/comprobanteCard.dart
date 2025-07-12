import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ComprobanteCard extends StatelessWidget {
  final String nombre;
  final String cedula;
  final String concepto;
  final String membresia;
  final double montoTotal;
  final String? tipoPago;
  final double? montoDolares;
  final double? montoBolivares;
  final String fecha;

  const ComprobanteCard({
    super.key,
    required this.nombre,
    required this.cedula,
    required this.concepto,
    required this.membresia,
    required this.montoTotal,
    this.tipoPago,
    this.montoDolares,
    this.montoBolivares,
    required this.fecha,
  });

  void _compartirComprobanteComoPDF(BuildContext context) async {
    final pdf = pw.Document();

    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/avatar.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Encabezado
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(logoImage, width: 60, height: 60),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('GYM POWER FITNESS',
                        style: pw.TextStyle(
                            fontSize: 22, fontWeight: pw.FontWeight.bold)),
                    pw.Text('RIF: J-12345678-9'),
                    pw.Text('Caracas, Venezuela'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 15),
            pw.Divider(),

            // Título comprobante
            pw.Center(
              child: pw.Text(
                'COMPROBANTE DE PAGO',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Fecha
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('Fecha: $fecha',
                    style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.SizedBox(height: 10),

            // Datos del cliente
            // Datos del cliente en formato tabla
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(5),
              },
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey300),
              children: [
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Cédula:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(cedula),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Nombre:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(nombre),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Membresía:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(membresia),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Concepto:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(concepto),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Tipo de Pago:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(tipoPago ?? 'No especificado'),
                  ),
                ]),
                if (tipoPago == 'Ambos' || tipoPago == 'Dólares')
                  pw.TableRow(children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Monto \$:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                          '\$${montoDolares?.toStringAsFixed(2) ?? '0.00'}'),
                    ),
                  ]),
                if (tipoPago == 'Ambos' || tipoPago == 'Bolívares')
                  pw.TableRow(children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Monto Bs:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                          '${montoBolivares?.toStringAsFixed(2) ?? '0,00'} Bs'),
                    ),
                  ]),
              ],
            ),
            pw.SizedBox(height: 12),

// Total destacado
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              color: PdfColors.grey200,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Monto Total:',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$${montoTotal.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800)),
                ],
              ),
            ),
            pw.Spacer(),

            pw.Divider(),

            pw.Center(
              child: pw.Text(
                '¡Gracias por su preferencia!',
                style:
                    pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/comprobante_pago.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Comprobante de Pago');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Container(
          width: size.width * 0.9,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  '📄 Comprobante de Pago',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 30, thickness: 1),
              TextLabelValue(label: 'Cédula:', value: cedula),
              TextLabelValue(label: 'Nombre:', value: nombre),
              TextLabelValue(label: 'Membresía:', value: membresia),
              TextLabelValue(label: 'Concepto:', value: concepto),
              TextLabelValue(
                  label: 'Tipo de Pago:', value: tipoPago ?? 'No especificado'),
              const SizedBox(height: 10),
              if (tipoPago == 'Dólares')
                TextLabelValue(
                  label: 'Monto en \$:',
                  value: '\$ ${montoTotal.toStringAsFixed(2) ?? '0.00'}',
                  valueColor: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
              if (tipoPago == 'Bolívares')
                TextLabelValue(
                  label: 'Monto en Bs:',
                  value: '${montoBolivares?.toStringAsFixed(2) ?? '0,00'} Bs',
                  valueColor: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),

              if (tipoPago == 'Ambos') ...[
                TextLabelValue(
                  label: 'Monto en Bs:',
                  value: '${montoBolivares?.toStringAsFixed(2) ?? '0,00'} Bs',
                  valueColor: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
                TextLabelValue(
                  label: 'Monto en \$:',
                  value: '\$ ${montoDolares?.toStringAsFixed(2) ?? '0.00'}',
                  valueColor: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
              ],
              const SizedBox(height: 12),
              TextLabelValue(
                label: 'Monto Total:',
                value: '\$ ${montoTotal.toStringAsFixed(2)}',
                valueColor: theme.colorScheme.onSurface,
                fontSize: 16,
              ),
              const SizedBox(height: 16),
              TextLabelValue(label: 'Fecha:', value: fecha),
              const SizedBox(height: 24),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _compartirComprobanteComoPDF(context),
                      icon: Icon(
                        Icons.share,
                        color: theme.colorScheme.onSurface,
                      ),
                      label: Text(
                        'Compartir',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            width: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Aquí puedes integrar un método de impresión con pdf/widgets si quieres
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Funcionalidad de impresión no implementada.'),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.print,
                        color: theme.colorScheme.onSurface
                      ),
                      label: Text(
                        'Imprimir',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            width: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: isDarkMode
                        ? theme.colorScheme.onInverseSurface
                        : theme.colorScheme.onSurface,
                  ),
                  label: Text(
                    'Aceptar',
                    style: TextStyle(
                      color: isDarkMode
                          ? theme.colorScheme.onInverseSurface
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        width: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final double? fontSize;

  const TextLabelValue({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label ',
              style:
                  theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
