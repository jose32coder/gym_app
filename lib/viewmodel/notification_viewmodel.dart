import 'package:basic_flutter/services/notification_services.dart';
import 'package:flutter/material.dart';

class NotificacionesViewModel extends ChangeNotifier {
  final NotificacionesService _service;

  NotificacionesViewModel(this._service);

  List<Map<String, dynamic>> _notificaciones = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get notificaciones => _notificaciones;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Suscripción para el stream de notificaciones
  Stream<List<Map<String, dynamic>>>? _notificacionesStream;

  void cargarNotificaciones(String gimnasioId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _notificacionesStream = _service.obtenerNotificaciones(gimnasioId);

    _notificacionesStream!.listen((lista) {
      _notificaciones = lista;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> agregarNotificacion(
      String gimnasioId, Map<String, dynamic> notificacion) async {
    try {
      await _service.guardarNotificacion(gimnasioId, notificacion);
    } catch (e) {
      _error = 'Error al guardar la notificación: $e';
      notifyListeners();
    }
  }
}
