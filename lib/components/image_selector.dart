import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Imageselector extends StatefulWidget {
  const Imageselector({super.key});

  @override
  State<Imageselector> createState() => _ImageselectorState();
}

class _ImageselectorState extends State<Imageselector> {
  @override
  Widget build(BuildContext context) {
    File? imageFile;

    final ImagePicker picker = ImagePicker();

    Future<void> pickImage() async {
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        setState(() {
          imageFile = File(pickedImage.path);
        });
      }
    }

    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Stack(children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: Colors.black87, // Color más suave y neutral
                width: 5,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white, // Color blanco para el fondo
              radius: 70,
              child: ClipOval(
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: imageFile != null
                      ? Transform.translate(
                          offset: const Offset(
                              0, 0), // mueve X e Y (positivo = derecha/abajo)
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image.file(imageFile!),
                          ),
                        )
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..translate(0.0, 15)
                            ..scale(1.1), // ajuste en el tamaño
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image.asset('assets/images/avatar.png'),
                          ),
                        ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent, // Cambio de color a azul
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          )
        ]));
  }
}
