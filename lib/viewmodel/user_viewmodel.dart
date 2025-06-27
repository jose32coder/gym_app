import 'package:basic_flutter/services/gimnasio_services.dart';
import 'package:basic_flutter/services/users_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserViewmodel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _gimnasioService = GimnasioService();
  final _userService = UserService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<String> crearCodigo() async {
    return await _gimnasioService.crearCodigo();
  }

  Future<void> guardarCodigoGenerado(String codigo) async {
    await _gimnasioService.guardarCodigoGenerado(codigo);
  }

  Future<bool> validarCodigoActivacion(String codigo, String uid) async {
    return await _gimnasioService.validarCodigoActivacion(codigo, uid);
  }

  Future<void> marcarCodigoComoUsado(String codigo, String uid) async {
    await _gimnasioService.marcarCodigoComoUsado(codigo, uid);
  }

  Future<Map<String, dynamic>?> obtenerDatosUsuario(String uid) async {
    return await _userService.getUserData(uid);
  }

  Future<Map<String, dynamic>?> obtenerDatosGym(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('gimnasios')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener datos usuario: $e');
      return null;
    }
  }

  Future<String> obtenerCodigoGimnasio(String uid) async {
    final userDoc = await _firestore.collection('usuarios').doc(uid).get();
    return userDoc.exists ? (userDoc.data()?['codigoGimnasio'] ?? '') : '';
  }

  Future<String?> crearGimnasioConCodigo({
    required String uid,
    required String codigo,
    required String nombreGimnasio,
    required String direccionGimnasio,
    required String telefonoGimnasio,
  }) async {
    _isLoading = true;
    notifyListeners();

    final batch = _firestore.batch();

    try {
      bool codigoValido =
          await _gimnasioService.validarCodigoActivacion(codigo, uid);
      if (!codigoValido) throw Exception('Código inválido o ya usado');

      // Obtener referencia de nuevo gimnasio
      final gimnasioRef = _firestore.collection('gimnasios').doc();

      // Crear gimnasio en batch
      batch.set(gimnasioRef, {
        'nombre': nombreGimnasio,
        'direccion': direccionGimnasio,
        'telefono': telefonoGimnasio,
        'propietario': uid,
        'codigo': codigo,
        'creadoEn': FieldValue.serverTimestamp(),
      });

      // Actualizar usuario en batch
      final usuarioRef = _firestore.collection('usuarios').doc(uid);
      batch.update(usuarioRef, {
        'codigoGimnasio': codigo,
        'tipo': 'Dueño',
      });

      // Crear subcolección de gimnasios dentro del usuario
      final usuarioGimnasioRef =
          usuarioRef.collection('gimnasios').doc(gimnasioRef.id);
      batch.set(usuarioGimnasioRef, {
        'nombreGimnasio': nombreGimnasio,
        'tipoUsuario': 'Dueño',
        'codigoGimnasio': codigo,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      // Marcar código como usado
      await _gimnasioService.marcarCodigoComoUsado(codigo, uid);

      // Ejecutar batch
      await batch.commit();

      _errorMessage = null;
      _successMessage = 'Gimnasio creado correctamente';

      return gimnasioRef.id;
    } catch (e) {
      _errorMessage = e.toString();
      _successMessage = null;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registrarUsuarioEnGimnasio({
    required String usuarioId,
    required String tipoUsuario,
    required String gimnasioId,
    String? nombre,
    String? cedula,
    String? apellido,
    double? talla,
    double? peso,
    String? membresia,
    double? pago,
    String? codigoActivacion,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userDoc =
          await _firestore.collection('usuarios').doc(usuarioId).get();
      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado');
      }

      final gimnasioDoc =
          await _firestore.collection('gimnasios').doc(gimnasioId).get();
      if (!gimnasioDoc.exists) {
        throw Exception('Gimnasio no encontrado');
      }

      final nombreGimnasio =
          gimnasioDoc.data()?['nombre'] ?? 'Nombre no disponible';
      final codigoDesdeGimnasio = gimnasioDoc.data()?['codigo'] ?? 'Sin código';

      final codigoFinal = codigoActivacion ?? codigoDesdeGimnasio;

      final userData = {
        'uid': usuarioId,
        'nombre': nombre ?? userDoc['nombre'],
        'apellido': apellido ?? userDoc['apellido'],
        'cedula': cedula ?? userDoc['cedula'],
        'tipo': tipoUsuario,
        'codigoGimnasio': codigoFinal,
        'talla': tipoUsuario == 'Cliente' ? talla : '',
        'peso': tipoUsuario == 'Cliente' ? peso : '',
        'membresia': tipoUsuario == 'Cliente' ? membresia : '',
        'pago': tipoUsuario == 'Cliente' ? pago : '',
        'habilitado': true,
        'estado': 'activo',
        'fechaUltimoPago':
            tipoUsuario == 'Cliente' ? FieldValue.serverTimestamp() : '',
      };

      await _firestore.collection('usuarios').doc(usuarioId).update({
        'codigoGimnasio': codigoFinal,
        'tipo': tipoUsuario,
      });

      await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('usuarios')
          .doc(usuarioId)
          .set(userData);

      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('gimnasios')
          .doc(gimnasioId)
          .set({
        'nombreGimnasio': nombreGimnasio,
        'tipoUsuario': tipoUsuario,
        'codigoGimnasio': codigoFinal,
        'habilitado': true,
      });

      _errorMessage = null;
      _successMessage = 'Usuario registrado correctamente';
    } catch (e) {
      _errorMessage = e.toString();
      _successMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> obtenerUsuariosDeGimnasio(
      String gimnasioId) async {
    _isLoading = true;
    notifyListeners();
    print('obtenerUsuariosDeGimnasio llamado con ID: $gimnasioId');
    try {
      final querySnapshot = await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('usuarios')
          .get();

      final usuarios = querySnapshot.docs
          .map((doc) => {'uid': doc.id, ...doc.data()})
          .toList();

      // 📌 Aquí imprimes los usuarios para verificar
      print('Usuarios obtenidos: $usuarios');

      _errorMessage = null;
      _successMessage = 'Usuarios obtenidos correctamente';

      return usuarios;
    } catch (e) {
      _errorMessage = 'Error al obtener usuarios: $e';
      _successMessage = null;
      print('Error al obtener usuarios: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>>
      cargarUsuariosDelGimnasioDelUsuarioActual() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final gimnasioId =
        await _gimnasioService.obtenerGimnasioIdDesdeUsuario(user.uid);
    return await obtenerUsuariosDeGimnasio(gimnasioId);
  }
}
