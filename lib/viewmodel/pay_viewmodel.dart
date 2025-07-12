import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PayViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? gimnasioId;
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> get payments => _payments;
  final bool _isLoading = false;
  bool get isLoading => _isLoading;

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
  Future<void> registrarPago(
      {required String cedula,
      required String nombre,
      required String nombreMembresia,
      required String membresiaId, // nuevo parámetro
      required double monto,
      required String observation,
      required String tipoPago,
      String? reference,
      double? montoBs,
      double? montoDollar,
      required DateTime fechaPago,
      required DateTime? fechaCorte}) async {
    if (gimnasioId == null) {
      await cargarGimnasioId();
      if (gimnasioId == null) return;
    }

    // Buscar usuario
    final usuariosQuery = await _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('usuarios')
        .where('cedula', isEqualTo: cedula)
        .limit(1)
        .get();

    if (usuariosQuery.docs.isEmpty) return;

    final usuarioDoc = usuariosQuery.docs.first;
    final usuarioId = usuarioDoc.id;

    // Registrar pago
    await _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('pagos')
        .add({
      'cedula': cedula,
      'nombre': nombre,
      'monto': monto,
      'tipoPago': tipoPago,
      'montoBs': montoBs,
      'montoDollares': montoDollar,
      'nombreMembresia': nombreMembresia,
      'referencia': reference,
      'fechaPago': fechaPago,
      'fechaCorte': fechaCorte,
      'observacion': observation,
    });

    // Actualizar datos del usuario
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
      'fechaVencimiento': fechaCorte
    });

    // Registrar al usuario en la membresía
    await _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('membresias')
        .doc(membresiaId)
        .collection('usuarios')
        .doc(cedula)
        .set({
      'cedula': cedula,
      'nombre': nombre,
      'estado': 'activo',
      'fechaPago': fechaPago,
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

      _payments = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print(data);

        return {
          'cedula': data['cedula'] ?? '',
          'nombre': data['nombre'] ?? '',
          'nombreMembresia': data['nombreMembresia'] ?? '',
          'monto': data['monto'] ?? 0.0,
          'tipoPago': data['tipoPago'] ?? '',
          'montoBs': data['montoBs'] ?? 0.0,
          'referencia': data['referencia'] ?? '', // <- string por defecto
          'montoDollares': data['montoDollares'] ?? 0.0, // <- num por defecto
          'fechaPago': (data['fechaPago'] as Timestamp).toDate(),
        };
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error al obtener pagos: $e');
    }
  }
}
