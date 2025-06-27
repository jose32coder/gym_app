import 'package:basic_flutter/models/model_promo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PromotionViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> guardarPromocion({
    required String? usuarioId,
    required PromotionModel promotion,
  }) async {
    try {
      final userDoc =
          await _firestore.collection('usuarios').doc(usuarioId).get();
      if (!userDoc.exists) throw Exception('Usuario no encontrado');

      final userData = userDoc.data()!;
      final codigoGimnasioUsuario = userData['codigoGimnasio'] ?? '';
      if (codigoGimnasioUsuario.isEmpty) {
        throw Exception('El usuario no tiene código de gimnasio asignado');
      }

      final gimnasioQuery = await _firestore
          .collection('gimnasios')
          .where('codigo', isEqualTo: codigoGimnasioUsuario.substring(0, 8))
          .limit(1)
          .get();

      if (gimnasioQuery.docs.isEmpty) {
        throw Exception('Gimnasio no encontrado');
      }

      final gimnasioId = gimnasioQuery.docs.first.id;

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

  Future<String> obtenerGimnasioId(String usuarioId) async {
    final userDoc =
        await _firestore.collection('usuarios').doc(usuarioId).get();
    if (!userDoc.exists) throw Exception('Usuario no encontrado');

    final userData = userDoc.data()!;
    final codigoGimnasioUsuario = userData['codigoGimnasio'] ?? '';
    if (codigoGimnasioUsuario.isEmpty) {
      throw Exception('El usuario no tiene código de gimnasio asignado');
    }

    final gimnasioQuery = await _firestore
        .collection('gimnasios')
        .where('codigo', isEqualTo: codigoGimnasioUsuario.substring(0, 8))
        .limit(1)
        .get();

    if (gimnasioQuery.docs.isEmpty) throw Exception('Gimnasio no encontrado');

    return gimnasioQuery.docs.first.id;
  }

  Stream<List<PromotionModel>> obtenerPromocionesPorUsuario(
      String usuarioId) async* {
    final gimnasioId = await obtenerGimnasioId(usuarioId);

    yield* _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('promociones')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PromotionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<PromotionModel>> obtenerMembresiasActivasPorUsuario(
      String usuarioId) async {
    try {
      // Obtener documento de usuario
      final docUsuario =
          await _firestore.collection('usuarios').doc(usuarioId).get();

      if (!docUsuario.exists) {
        print('El usuario no existe');
        return [];
      }

      final codigoGimnasio = docUsuario.get('codigoGimnasio');
      if (codigoGimnasio == null || codigoGimnasio.isEmpty) {
        print('El usuario no tiene código de gimnasio asignado');
        return [];
      }

      // Buscar gimnasio cuyo campo 'codigo' coincida con el código del usuario
      final gimnasioQuery = await _firestore
          .collection('gimnasios')
          .where('codigo', isEqualTo: codigoGimnasio)
          .limit(1)
          .get();

      if (gimnasioQuery.docs.isEmpty) {
        print('No se encontró gimnasio con código: $codigoGimnasio');
        return [];
      }

      final gimnasioId = gimnasioQuery.docs.first.id;

      // Obtener membresías activas
      final membresiasQuery = await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('membresias')
          .where('isActive', isEqualTo: true)
          .get();

      // Convertir documentos a Membership
      final membresias = membresiasQuery.docs
          .map((doc) => PromotionModel.fromFirestore(doc))
          .toList();

      return membresias;
    } catch (e) {
      print('Error al obtener membresías activas: $e');
      return [];
    }
  }
}
