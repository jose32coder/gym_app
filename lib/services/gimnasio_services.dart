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
        .where('propietario', isEqualTo: usuarioId)
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

  Future<String> obtenerCodigoGimnasio(String gimnasioId) async {
    if (gimnasioId.isEmpty) return '';

    final doc = await FirebaseFirestore.instance
        .collection('gimnasios')
        .doc(gimnasioId)
        .get();

    if (doc.exists && doc.data() != null) {
      return doc.data()!['codigo'] ?? '';
    } else {
      return '';
    }
  }

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

  Future<String> crearGimnasio({
    required String propietarioUid,
    required String nombre,
    required String direccion,
    required String telefono,
    required String codigo,
  }) async {
    final docRef = _db.collection('gimnasios').doc(); // Genera ID automático

    await docRef.set({
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'propietario': propietarioUid,
      'codigo': codigo,
      'fechaRegistro': FieldValue.serverTimestamp(),
      'usado': false
    });

    return docRef.id;
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
    ;

    final collectionName;

    if (tipoUsuario == 'Cliente') {
      collectionName = 'clientes';
    } else if (tipoUsuario == 'Administrador') {
      collectionName = 'administradores';
    } else if (tipoUsuario == 'Dueño') {
      collectionName = 'dueños'; // o 'duenos' si prefieres separarlo
    } else {
      throw Exception('Tipo de usuario inválido');
    }

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
