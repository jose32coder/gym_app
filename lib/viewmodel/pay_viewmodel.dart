import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PayViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? gimnasioId;
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> get payments => _payments;

  /// Obtiene el gimnasioId del usuario actual
  Future<void> cargarGimnasioId() async {
    final usuarioId = _auth.currentUser?.uid;
    if (usuarioId == null) {
      return;
    }

    final docUsuario =
        await _firestore.collection('usuarios').doc(usuarioId).get();
    if (!docUsuario.exists) {
      return;
    }

    final codigoGimnasio = docUsuario.get('codigoGimnasio');
    if (codigoGimnasio == null || codigoGimnasio.isEmpty) {
      return;
    }

    final gimnasioQuery = await _firestore
        .collection('gimnasios')
        .where('codigo', isEqualTo: codigoGimnasio)
        .limit(1)
        .get();

    if (gimnasioQuery.docs.isEmpty) {
      return;
    }

    gimnasioId = gimnasioQuery.docs.first.id;
    await fetchPayments();
    notifyListeners();
  }

  /// Guarda un nuevo pago y actualiza datos del usuario
  Future<void> registrarPago({
    required String cedula,
    required String nombre,
    required String nombreMembresia,
    required double monto,
    double? montoBs,
    double? montoDollar,
    required DateTime fechaPago,
  }) async {
    if (gimnasioId == null) {
      await cargarGimnasioId();
      if (gimnasioId == null) {
        return;
      }
    }

    // Buscar usuario en: gimnasios/{gimnasioId}/usuarios/
    final usuariosQuery = await _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('usuarios')
        .where('cedula', isEqualTo: cedula)
        .limit(1)
        .get();

    if (usuariosQuery.docs.isEmpty) {
      return;
    }

    final usuarioDoc = usuariosQuery.docs.first;
    final usuarioId = usuarioDoc.id;

    // Registrar pago en: gimnasios/{gimnasioId}/pagos/
    await _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('pagos')
        .add({
      'cedula': cedula,
      'nombre': nombre,
      'monto': monto,
      'montoBs': montoBs,
      'montoDollar': montoDollar,
      'nombreMembresia': nombreMembresia,
      'fechaPago': fechaPago,
    });
    // Actualizar datos del usuario en: gimnasios/{gimnasioId}/usuarios/{usuarioId}
    await _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('usuarios')
        .doc(usuarioId)
        .update({
      'estado': 'activo',
      'habilitado': true,
      'fechaUltimoPago': fechaPago,
      'membresia': nombreMembresia,
    });
  }

  Future<void> fetchPayments() async {
    if (gimnasioId == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('pagos')
          .orderBy('fechaPago', descending: true)
          .get();

      print('Documentos encontrados: ${querySnapshot.docs.length}');

      _payments = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'cedula': data['cedula'] ?? '',
          'nombre': data['nombre'] ?? '',
          'nombreMembresia': data['nombreMembresia'] ?? '',
          'monto': data['monto'] ?? 0.0,
          'montoBs': data['montoBs'] ?? 0.0,
          'montoDollar': data['montoDollar'] ?? 0.0,
          'fechaPago': (data['fechaPago'] as Timestamp).toDate(),
        };
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error al obtener pagos: $e');
    }
  }
}
