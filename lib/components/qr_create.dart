import 'dart:math';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CodigoService {
  String _generarCodigoAleatorio(int longitud) {
    const caracteres = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        longitud,
        (_) => caracteres.codeUnitAt(random.nextInt(caracteres.length)),
      ),
    );
  }

  String generarCodigoActivacion(String codigoGimnasio, int longitudAleatoria) {
    final codigoAleatorio = _generarCodigoAleatorio(longitudAleatoria);
    return '$codigoGimnasio-$codigoAleatorio';
  }

  Future<String?> generarQRComoArchivo(GlobalKey globalKey) async {
    try {
      final boundary = globalKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/codigo_qr.png');
      await file.writeAsBytes(pngBytes);

      return file.path;
    } catch (e) {
      debugPrint("Error generando QR: $e");
      return null;
    }
  }

  Future<void> compartirCodigo({
    required String codigoGenerado,
    required String qrPath,
    required BuildContext context,
  }) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.shareXFiles(
      [XFile(qrPath)],
      text: 'Este es tu código de activación: $codigoGenerado',
      subject: 'Código de activación',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}
