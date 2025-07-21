import 'package:basic_flutter/services/gimnasio_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificacionesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GimnasioService _gimnasioService = GimnasioService();

  Future<void> guardarNotificacion(
      String usuarioId, Map<String, dynamic> notificacion) async {
    final gimnasioId = await _gimnasioService.obtenerGimnasioId(usuarioId);

    await _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('notificaciones')
        .add(notificacion);
  }

  Stream<List<Map<String, dynamic>>> obtenerNotificaciones(String gimnasioId) {
    return _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('notificaciones')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
