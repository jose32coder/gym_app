import 'package:basic_flutter/services/gimnasio_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PersonasViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _gimnasioService = GimnasioService();

  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> get usuarios => _usuarios;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? rolUsuario;
  String? usuarioActivoId;

  String? tipoUsuario;

  late String gimnasioId;
  late String codigo;

  Future<void> cargarUsuarios() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _usuarios = [];
        rolUsuario = null;
        usuarioActivoId = null;
        gimnasioId = '';
        _isLoading = false;
        notifyListeners();
        return;
      }

      usuarioActivoId = user.uid;
      print('Usuario activo ID: $usuarioActivoId');

      // Obtén el documento del usuario para saber su rol
      final userDoc =
          await _firestore.collection('usuarios').doc(user.uid).get();

      if (!userDoc.exists || userDoc.data() == null) {
        _usuarios = [];
        rolUsuario = null;
        gimnasioId = '';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final data = userDoc.data()!;
      rolUsuario = data['tipo'] as String? ?? '';

      // Obtén el gimnasioId desde tu servicio o directamente del documento
      gimnasioId = await _gimnasioService
          .obtenerGimnasioIdDesdeUsuario(usuarioActivoId!);
      print('Gimnasio ID: $gimnasioId');
      codigo = await _gimnasioService.obtenerCodigoGimnasio(gimnasioId);

      print('Código gimnasio: $codigo');

      if (rolUsuario == 'Cliente') {
        _usuarios = [];
      } else if (rolUsuario == 'Administrador' || rolUsuario == 'Dueño') {
        _usuarios = await obtenerUsuariosDeGimnasio(gimnasioId);
        print('Usuarios obtenidos: $_usuarios');
      } else {
        _usuarios = [];
      }
    } catch (e) {
      _errorMessage = 'Error al cargar usuarios: $e';
      _usuarios = [];
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> obtenerUsuariosDeGimnasio(
      String gimnasioId) async {
    final querySnapshot = await _firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('usuarios')
        .get();

    return querySnapshot.docs
        .map((doc) => {'uid': doc.id, ...doc.data()})
        .toList();
  }

  Future<void> cargarTipoUsuario() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        tipoUsuario = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final doc = await _firestore.collection('usuarios').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        tipoUsuario = doc.data()!['tipo'] as String?;
      } else {
        tipoUsuario = null;
      }
    } catch (e) {
      tipoUsuario = null;
      // Manejar el error (log, mensaje, etc.)
    }

    _isLoading = false;
    notifyListeners();
  }
}
