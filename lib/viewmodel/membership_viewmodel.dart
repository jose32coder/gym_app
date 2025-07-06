import 'package:basic_flutter/models/model_membership.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MembershipViewmodel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> guardarMembresia({
    required String? usuarioId,
    required MembershipModel membership,
  }) async {
    try {
      // 1. Obtener usuario
      final userDoc =
          await _firestore.collection('usuarios').doc(usuarioId).get();
      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado');
      }
      final userData = userDoc.data()!;
      final codigoGimnasioUsuario = userData['codigoGimnasio'] ?? '';

      if (codigoGimnasioUsuario.isEmpty) {
        throw Exception('El usuario no tiene código de gimnasio asignado');
      }

      // 2. Buscar gimnasio con el código que coincide (puedes ajustar el substring según la lógica)
      final gimnasioQuery = await _firestore
          .collection('gimnasios')
          .where('codigo', isEqualTo: codigoGimnasioUsuario.substring(0, 8))
          .limit(1)
          .get();

      if (gimnasioQuery.docs.isEmpty) {
        throw Exception(
            'Gimnasio con código ${codigoGimnasioUsuario.substring(0, 8)} no encontrado');
      }

      final gimnasioDoc = gimnasioQuery.docs.first;
      final gimnasioId = gimnasioDoc.id;

      final membershipData = {
        'name': membership.name,
        'price': membership.price,
        'membershipType': membership.membershipType,
        'isActive': membership.isActive,
      };

      // 4. Guardar en gimnasios/{gimnasioId}/membresias/{usuarioId}
      final docRef = await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('membresias')
          .add(membershipData);

      final newMembershipId = docRef.id;
      print('Nueva membresía creada con ID: $newMembershipId');

      notifyListeners();
    } catch (e) {
      print('Error al guardar membresía: $e');
      rethrow;
    }
  }

  Future<void> actualizarMembresia({
    required String? usuarioId,
    required String membershipId,
    required MembershipModel membership,
  }) async {
    try {
      // 1. Obtener código de gimnasio asociado al usuario
      final userDoc =
          await _firestore.collection('usuarios').doc(usuarioId).get();
      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado');
      }
      final userData = userDoc.data()!;
      final codigoGimnasioUsuario = userData['codigoGimnasio'] ?? '';

      if (codigoGimnasioUsuario.isEmpty) {
        throw Exception('El usuario no tiene código de gimnasio asignado');
      }

      // 2. Buscar gimnasio con el código que coincide
      final gimnasioQuery = await _firestore
          .collection('gimnasios')
          .where('codigo', isEqualTo: codigoGimnasioUsuario.substring(0, 8))
          .limit(1)
          .get();

      if (gimnasioQuery.docs.isEmpty) {
        throw Exception(
            'Gimnasio con código ${codigoGimnasioUsuario.substring(0, 8)} no encontrado');
      }

      final gimnasioDoc = gimnasioQuery.docs.first;
      final gimnasioId = gimnasioDoc.id;

      final updatedData = {
        'name': membership.name,
        'price': membership.price,
        'membershipType': membership.membershipType,
        'isActive': membership.isActive,
      };

      // 4. Actualizar documento de membresía
      await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('membresias')
          .doc(membershipId)
          .update(updatedData);

      notifyListeners();
    } catch (e) {
      print('Error al actualizar membresía: $e');
      rethrow;
    }
  }

  Future<String> obtenerGimnasioId(String usuarioId) async {
    final userDoc =
        await _firestore.collection('usuarios').doc(usuarioId).get();
    if (!userDoc.exists) {
      throw Exception('Usuario no encontrado');
    }
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
      throw Exception(
          'Gimnasio con código ${codigoGimnasioUsuario.substring(0, 8)} no encontrado');
    }

    return gimnasioQuery.docs.first.id;
  }

  Future<void> toggleMembershipActiveStatus(
      String membershipId, bool currentStatus, String usuarioId) async {
    final userDoc =
        await _firestore.collection('usuarios').doc(usuarioId).get();
    if (!userDoc.exists) {
      throw Exception('Usuario no encontrado');
    }
    final userData = userDoc.data()!;
    final codigoGimnasioUsuario = userData['codigoGimnasio'] ?? '';

    if (codigoGimnasioUsuario.isEmpty) {
      throw Exception('El usuario no tiene código de gimnasio asignado');
    }

    // Buscar gimnasio por código
    final gimnasioQuery = await _firestore
        .collection('gimnasios')
        .where('codigo', isEqualTo: codigoGimnasioUsuario.substring(0, 8))
        .limit(1)
        .get();

    if (gimnasioQuery.docs.isEmpty) {
      throw Exception(
          'Gimnasio con código ${codigoGimnasioUsuario.substring(0, 8)} no encontrado');
    }

    final gimnasioDoc = gimnasioQuery.docs.first;
    final gimnasioId = gimnasioDoc.id;

    // Buscar usuarios activos en la membresía de ese gimnasio
    final usuariosActivosQuery = await _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('membresias')
        .doc(membershipId)
        .collection('usuarios')
        .where('estado', isEqualTo: 'activo')
        .get();

    if (usuariosActivosQuery.docs.isNotEmpty) {
      throw ('No se puede desactivar esta membresía porque hay usuarios activos asignados a ella.');
    }

    // Cambiar el estatus de la membresía
    final newStatus = !currentStatus;
    await _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('membresias')
        .doc(membershipId)
        .update({'isActive': newStatus});
  }

  Stream<List<MembershipModel>> obtenerMembresiasPorUsuario(
      String usuarioId) async* {
    try {
      final docUsuario =
          await _firestore.collection('usuarios').doc(usuarioId).get();
      if (!docUsuario.exists) {
        print('El usuario no existe');
        yield [];
        return;
      }

      final codigoGimnasio = docUsuario.get('codigoGimnasio');
      if (codigoGimnasio == null || codigoGimnasio.isEmpty) {
        print('El usuario no tiene código de gimnasio asignado');
        yield [];
        return;
      }
      print('Código de gimnasio obtenido: "$codigoGimnasio"');
      // Buscar gimnasio cuyo campo 'codigo' coincida con el código del usuario
      final gimnasioQuery = await _firestore
          .collection('gimnasios')
          .where('codigo', isEqualTo: codigoGimnasio.substring(0, 8))
          .limit(1)
          .get();

      if (gimnasioQuery.docs.isEmpty) {
        print('No se encontró gimnasio con código: $codigoGimnasio');
        yield [];
        return;
      }

      final gimnasioId = gimnasioQuery.docs.first.id;

      print('Buscando membresías en gimnasioId: $gimnasioId');

      yield* _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('membresias')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MembershipModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      print('Error al obtener membresías: $e');
      yield [];
    }
  }

  Stream<List<MembershipModel>> obtenerUsuariosPorMembresia(
      String gimnasioId, String membresiaId) {
    return _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('membresias')
        .doc(membresiaId)
        .collection('usuarios')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MembershipModel.fromFirestore(doc))
            .toList());
  }

  // Future<List<MembershipModel>> obtenerMembresiasActivasPorUsuario(
  //     String usuarioId) async {
  //   try {
  //     // Obtener documento de usuario
  //     final docUsuario =
  //         await _firestore.collection('usuarios').doc(usuarioId).get();

  //     if (!docUsuario.exists) {
  //       print('El usuario no existe');
  //       return [];
  //     }

  //     final codigoGimnasio = docUsuario.get('codigoGimnasio');
  //     if (codigoGimnasio == null || codigoGimnasio.isEmpty) {
  //       print('El usuario no tiene código de gimnasio asignado');
  //       return [];
  //     }

  //     // Buscar gimnasio cuyo campo 'codigo' coincida con el código del usuario
  //     final gimnasioQuery = await _firestore
  //         .collection('gimnasios')
  //         .where('codigo', isEqualTo: codigoGimnasio)
  //         .limit(1)
  //         .get();

  //     if (gimnasioQuery.docs.isEmpty) {
  //       print('No se encontró gimnasio con código: $codigoGimnasio');
  //       return [];
  //     }

  //     final gimnasioId = gimnasioQuery.docs.first.id;

  //     // Obtener membresías activas
  //     final membresiasQuery = await _firestore
  //         .collection('gimnasios')
  //         .doc(gimnasioId)
  //         .collection('membresias')
  //         .where('isActive', isEqualTo: true)
  //         .get();

  //     // Convertir documentos a Membership
  //     final membresias = membresiasQuery.docs
  //         .map((doc) => MembershipModel.fromFirestore(doc))
  //         .toList();

  //     return membresias;
  //   } catch (e) {
  //     print('Error al obtener membresías activas: $e');
  //     return [];
  //   }
  // }
}
