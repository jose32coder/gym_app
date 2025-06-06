import 'package:cloud_firestore/cloud_firestore.dart';

class GimnasioService {
  final _db = FirebaseFirestore.instance;

  Future<bool> validarCodigoActivacion(String codigo, String uid) async {
    final doc = await _db.collection('codigos_activacion').doc(codigo).get();

    if (!doc.exists) {
      return false; // código no existe
    }

    final data = doc.data();
    if (data == null) {
      return false; // documento sin datos
    }

    if (data['usado'] == true) {
      return false; // código ya usado
    }

    await _db.collection('codigos_activacion').doc(codigo).update({
      'usado': true,
      'usadoPor': uid,
      'fechaUso': FieldValue.serverTimestamp(),
    });

    return true;
  }

  Future<void> crearGimnasio({
    required String uid,
    required String nombre,
    required String direccion,
    required String telefono,
  }) async {
    await _db.collection('gimnasios').doc(uid).set({
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'duenho': uid,
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }
}
