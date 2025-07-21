import 'package:basic_flutter/services/gimnasio_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PayViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GimnasioService _gimnasioService = GimnasioService();

  String? gimnasioId;
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> get payments => _payments;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Carga el gimnasioId desde el servicio centralizado
  Future<void> cargarGimnasioId() async {
    _isLoading = true;
    notifyListeners();

    try {
      final usuarioId = _auth.currentUser?.uid;
      if (usuarioId == null) return;

      gimnasioId = await _gimnasioService.obtenerGimnasioId(usuarioId);
      await fetchPayments();
    } catch (e) {
      debugPrint('Error en cargarGimnasioId: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registrarPago({
    required String cedula,
    required String nombre,
    required String nombreMembresia,
    required String membresiaId,
    required double monto,
    required String observation,
    required String tipoPago,
    String? reference,
    double? montoBs,
    double? montoDollar,
    required DateTime fechaPago,
    required DateTime? fechaCorte,
  }) async {
    final usuarioId = _auth.currentUser?.uid;
    if (usuarioId == null) return;

    gimnasioId ??= await _gimnasioService.obtenerGimnasioId(usuarioId);
    if (gimnasioId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

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
        'fechaVencimiento': fechaCorte,
      });

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
    } catch (e) {
      debugPrint('Error en registrarPago: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPayments() async {
    if (gimnasioId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('pagos')
          .orderBy('fechaPago', descending: true)
          .get();

      _payments = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'cedula': data['cedula'] ?? '',
          'nombre': data['nombre'] ?? '',
          'nombreMembresia': data['nombreMembresia'] ?? '',
          'monto': data['monto'] ?? 0.0,
          'tipoPago': data['tipoPago'] ?? '',
          'montoBs': data['montoBs'] ?? 0.0,
          'referencia': data['referencia'] ?? '',
          'montoDollares': data['montoDollares'] ?? 0.0,
          'fechaPago': (data['fechaPago'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error al obtener pagos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
