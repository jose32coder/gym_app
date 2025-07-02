import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/viewmodel/user_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CreateCode extends StatefulWidget {
  const CreateCode({super.key});

  @override
  State<CreateCode> createState() => _CreateCodeState();
}

class _CreateCodeState extends State<CreateCode> {
  String? codigoGenerado;
  String? uid;

  final GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    obtenerCodigoGimnasio();
  }

  String generarCodigoAleatorio(int longitud) {
    const caracteres = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        longitud,
        (_) => caracteres.codeUnitAt(random.nextInt(caracteres.length)),
      ),
    );
  }

  Future<void> obtenerCodigoGimnasio() async {
    try {
      final userViewModel = Provider.of<UserViewmodel>(context, listen: false);
      uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        final codigo = await userViewModel.obtenerCodigoGimnasio(uid!);

        if (mounted) {
          final codigoRecortado =
              codigo.length >= 8 ? codigo.substring(0, 8) : codigo;
          final codigoAleatorio = generarCodigoAleatorio(5);
          final codigoFinal = '$codigoRecortado-$codigoAleatorio';

          setState(() {
            codigoGenerado = codigoFinal;
          });
        }
      } else {
        debugPrint("No hay usuario autenticado.");
      }
    } catch (e) {
      debugPrint("Error al obtener código gimnasio: $e");
    }
  }

  Future<void> guardarCodigo() async {
    if (codigoGenerado == null || uid == null) {
      debugPrint(
          "No se puede guardar porque no hay código generado o usuario.");
      return;
    }

    final userViewModel = Provider.of<UserViewmodel>(context, listen: false);
    await userViewModel.guardarCodigoGenerado(codigoGenerado!);
  }

  Future<void> compartirCodigo() async {
    if (codigoGenerado == null) return;

    final qrPath = await generarQRComoArchivo();
    if (qrPath == null) return;

    final box = context.findRenderObject() as RenderBox?;
    await Share.shareXFiles(
      [XFile(qrPath)],
      text: 'Este es tu código de activación: $codigoGenerado',
      subject: 'Código de activación',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<String?> generarQRComoArchivo() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/codigo_qr.png');
      await file.writeAsBytes(pngBytes);

      return file.path;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crear Código',
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (codigoGenerado != null)
                const Text(
                  'Ultimo codigo generado',
                  style: TextStyle(fontSize: 18),
                ),
              const SizedBox(height: 20),
              if (codigoGenerado != null)
                Column(
                  children: [
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Código generado:',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              codigoGenerado!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    RepaintBoundary(
                      key: globalKey,
                      child: QrImageView(
                        data: codigoGenerado!,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: isDarkMode
                            ? theme.colorScheme.onInverseSurface
                            : theme.colorScheme.onSurface,
                        foregroundColor: isDarkMode
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onInverseSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: compartirCodigo,
                            icon: Icon(
                              Icons.download,
                              color: isDarkMode
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onInverseSurface,
                              size: 22,
                            ),
                            label: Text(
                              'Descargar QR',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onInverseSurface),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 45),
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: compartirCodigo,
                            icon: Icon(
                              Icons.share,
                              color: isDarkMode
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onInverseSurface,
                              size: 22,
                            ),
                            label: Text(
                              'Compartir',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onInverseSurface),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(
                                  0, 45), // ancho 0 porque Expanded controla
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
                    Center(
                      child: Expanded(
                        child: ElevatedButton.icon(
                          onPressed: guardarCodigo,
                          icon: Icon(
                            Icons.save,
                            color: isDarkMode
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onInverseSurface,
                            size: 22,
                          ),
                          label: Text(
                            'Guardar Codigo',
                            style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onInverseSurface),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(
                                0, 45), // ancho 0 porque Expanded controla
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: obtenerCodigoGimnasio,
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        const Size(0, 45), // ancho 0 porque Expanded controla
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Generar nuevo código',
                    style: TextStyle(
                      color: isDarkMode
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onInverseSurface,
                      fontSize: 18,
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
