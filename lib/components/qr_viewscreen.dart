import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrViewscreen extends StatefulWidget {
  const QrViewscreen({super.key});

  @override
  State<QrViewscreen> createState() => _QrViewscreenState();
}

class _QrViewscreenState extends State<QrViewscreen> {
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Escanear Código QR',
          style: TextStyles.boldPrimaryText(context),
        ),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (!isScanning) return; // evitar múltiples lecturas

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            setState(() {
              isScanning = false; // detener lectura
            });
            Navigator.of(context).pop(barcodes.first.rawValue);
          }
        },
      ),
    );
  }
}
