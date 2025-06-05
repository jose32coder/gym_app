import 'package:basic_flutter/models/user_register_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class UserViewmodel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerPerson(UserRegisterModels usern) async {
    try {
      await _firestore.collection('usuarios').add(usern.toJson());
      debugPrint('Persona registrada correctamente');
    } catch (e) {
      debugPrint('Error al registrar persona: $e');
    }
  }
  Future<bool> validarCodigoActivacion(String codigo, String uid) async {
  final doc = await FirebaseFirestore.instance
      .collection('codigosActivacion')
      .doc(codigo)
      .get();

  if (!doc.exists) {
    return false;
  }

  final data = doc.data();
  if (data == null || data['activo'] != true) {
    return false;
  }

  await FirebaseFirestore.instance
      .collection('codigosActivacion')
      .doc(codigo)
      .update({
    'activo': false,
    'asignadoA': uid,
    'fechaActivacion': DateTime.now()
  });

  return true;
}

Future<void> crearGimnasio(String uid) async {
  await FirebaseFirestore.instance.collection('gimnasios').doc(uid).set({
    'nombre': 'Nuevo gimnasio',
    'creadoPor': uid,
    'fechaCreacion': DateTime.now(),
  });
}

}
