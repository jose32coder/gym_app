import 'package:basic_flutter/models/model_promo.dart';
import 'package:basic_flutter/services/gimnasio_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PromotionViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GimnasioService gimnasioService;

  PromotionViewModel(this.gimnasioService);

  Future<void> guardarPromocion({
    required String? usuarioId,
    required PromotionModel promotion,
  }) async {
    try {
      if (usuarioId == null) throw Exception('Usuario ID es requerido');
      final gimnasioId = await gimnasioService.obtenerGimnasioId(usuarioId);

      final docRef = await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('promociones')
          .add(promotion.toMap());

      print('Nueva promoción creada con ID: ${docRef.id}');
      notifyListeners();
    } catch (e) {
      print('Error al guardar promoción: $e');
      rethrow;
    }
  }

  Stream<List<PromotionModel>> obtenerPromocionesPorUsuario(String uid) async* {
    final gimnasioId = await gimnasioService.obtenerGimnasioId(uid);
    yield* _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('promociones')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PromotionModel.fromFirestore(doc))
            .toList());
  }

  Future<List<PromotionModel>> obtenerMembresiasActivasPorUsuario(
      String usuarioId) async {
    try {
      final gimnasioId = await gimnasioService.obtenerGimnasioId(usuarioId);

      final membresiasQuery = await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('membresias')
          .where('isActive', isEqualTo: true)
          .get();

      final membresias = membresiasQuery.docs
          .map((doc) => PromotionModel.fromFirestore(doc))
          .toList();

      return membresias;
    } catch (e) {
      print('Error al obtener membresías activas: $e');
      return [];
    }
  }

  Future<void> actualizarEstadoPromocion({
    required String usuarioId,
    required String? promocionId,
    required bool nuevoEstado,
  }) async {
    try {
      if (promocionId == null) throw Exception('ID de promoción es requerido');
      final gimnasioId = await gimnasioService.obtenerGimnasioId(usuarioId);

      await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('promociones')
          .doc(promocionId)
          .update({'isActive': nuevoEstado});

      notifyListeners();
    } catch (e) {
      print('Error al actualizar estado de promoción: $e');
      rethrow;
    }
  }
}
