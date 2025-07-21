import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class GimnasioService {
  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<bool> validarCodigoActivacion(String codigo, String uid) async {
    final doc = await _db.collection('codigos').doc(codigo).get();

    if (!doc.exists) return false;
    final data = doc.data();
    if (data == null) return false;

    return data['usado'] != true;
  }

  Future<String> obtenerGimnasioIdDesdeUsuario(String usuarioId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('gimnasios')
        .where('tipoUsuario', isEqualTo: usuarioId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final id = snapshot.docs.first.id;
      print('Gimnasio encontrado: $id');
      return id;
    } else {
      print('No se encontró gimnasio para usuario $usuarioId');
      return '';
    }
  }

  // Future<String> obtenerCodigoGimnasio(String gimnasioId) async {
  //   if (gimnasioId.isEmpty) return '';

  //   final doc = await FirebaseFirestore.instance
  //       .collection('gimnasios')
  //       .doc(gimnasioId)
  //       .get();

  //   if (doc.exists && doc.data() != null) {
  //     final codigoCompleto = doc.data()!['codigo'] ?? '';
  //     if (codigoCompleto.length >= 8) {
  //       return codigoCompleto.substring(0, 8);
  //     } else {
  //       return codigoCompleto; // Devuelve lo que haya si es menos de 8 caracteres
  //     }
  //   } else {
  //     return '';
  //   }
  // }

  Future<String> crearCodigo() async {
    final codigo = _uuid.v4().substring(0, 8).toUpperCase();

    await _db.collection('codigos').doc(codigo).set({
      'codigo': codigo,
      'usado': false,
      'creadoEn': DateTime.now(),
    });

    return codigo;
  }

  Future<void> guardarCodigoGenerado(String codigo) async {
    await _db.collection('codigos').doc(codigo).set({
      'codigo': codigo,
      'usado': false,
      'creadoEn': DateTime.now(),
    });
  }

  Future<void> marcarCodigoComoUsado(String codigo, String uid) async {
    await _db.collection('codigos').doc(codigo).update({
      'usado': true,
      'usadoPor': uid,
      'fechaUso': FieldValue.serverTimestamp(),
    });
  }

  Future<String> obtenerGimnasioId(String usuarioId) async {
    final userDoc = await _db.collection('usuarios').doc(usuarioId).get();

    if (!userDoc.exists) {
      throw Exception('Usuario no encontrado');
    }

    final userData = userDoc.data()!;
    final codigoGimnasioUsuario = userData['codigoGimnasio'] ?? '';

    if (codigoGimnasioUsuario.isEmpty) {
      throw Exception('El usuario no tiene código de gimnasio asignado');
    }

    final codigo = codigoGimnasioUsuario.substring(0, 8);

    final gimnasioQuery = await _db
        .collection('gimnasios')
        .where('codigo', isEqualTo: codigo)
        .limit(1)
        .get();

    if (gimnasioQuery.docs.isEmpty) {
      throw Exception('Gimnasio con código $codigo no encontrado');
    }

    return gimnasioQuery.docs.first.id;
  }
}
