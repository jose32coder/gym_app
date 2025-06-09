import 'package:cloud_firestore/cloud_firestore.dart';

class GimnasioService {
  final _db = FirebaseFirestore.instance;

  Future<bool> validarCodigoActivacion(String codigo, String uid) async {
    final doc = await _db.collection('activacion-codigos').doc(codigo).get();

    if (!doc.exists) return false;
    final data = doc.data();
    if (data == null) return false;

    return data['usado'] != true;
  }

  Future<void> marcarCodigoComoUsado(String codigo, String uid) async {
    await _db.collection('activacion-codigos').doc(codigo).update({
      'usado': true,
      'usadoPor': uid,
      'fechaUso': FieldValue.serverTimestamp(),
    });
  }

  Future<void> crearGimnasio({
    required String propietarioUid, // <- uid de usuario
    required String docID,
    required String nombre,
    required String direccion,
    required String telefono,
    required String codigo,
  }) async {
    await _db.collection('gimnasios').doc(docID).set({
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'propietario': propietarioUid,
      'codigo': codigo,
      'fechaRegistro': FieldValue.serverTimestamp(),
      'usado': false
    });
  }

  Future<void> registrarUsuarioEnGimnasio(
      {required String gimnasioId,
      required String usuarioId,
      required String tipoUsuario, // 'Cliente' o 'Administrador'
      String? nombre,
      String? apellido,
      double? talla,
      double? peso,
      String? membresia,
      double? pago}) async {
    final collectionName =
        tipoUsuario == 'Cliente' ? 'clientes' : 'administradores';

    final docRef = FirebaseFirestore.instance
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection(collectionName)
        .doc(usuarioId);

    // Construimos el mapa de datos a guardar, con campos según tipoUsuario
    Map<String, dynamic> data = {
      'nombre': nombre,
      'apellido': apellido,
      'registradoEn': FieldValue.serverTimestamp(),
    };

    if (tipoUsuario == 'Cliente') {
      data.addAll({
        'talla': talla,
        'peso': peso,
        'membresia': membresia,
        'pago': pago,
      });
    }

    await docRef.set(data);
  }

}
