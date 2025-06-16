import 'package:basic_flutter/models/user_register_models.dart';
import 'package:basic_flutter/services/gimnasio_services.dart';
import 'package:basic_flutter/services/users_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    try {
      bool codigoValido =
          await _gimnasioService.validarCodigoActivacion(codigo, uid);
      if (!codigoValido) {
        throw Exception('Código inválido o ya usado');
      }

      await _gimnasioService.marcarCodigoComoUsado(codigo, uid);

      final gimnasioId = await _gimnasioService.crearGimnasio(
        nombre: nombreGimnasio,
        direccion: direccionGimnasio,
        telefono: telefonoGimnasio,
        propietarioUid: uid,
        codigo: codigo,
      );

      // Actualizar código y tipo de usuario en el documento principal de usuarios
      await _firestore.collection('usuarios').doc(uid).update({
        'codigoGimnasio': codigo,
        'tipo': 'Dueño',
      });

      // Crear relación en subcolección de gimnasios del usuario
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('gimnasios')
          .doc(gimnasioId)
          .set({
        'nombreGimnasio': nombreGimnasio,
        'tipoUsuario': 'Dueño',
        'codigoGimnasio': codigo,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      _errorMessage = null;
      _successMessage = 'Gimnasio creado correctamente';

      return gimnasioId;
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
    String? codigoActivacion, // ← aquí
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

      // Usar codigoActivacion si viene, sino el del gimnasio
      final codigoFinal = codigoActivacion ?? codigoDesdeGimnasio;

      final userData = {
        'uid': usuarioId,
        'nombre': nombre ?? userDoc['nombre'],
        'apellido': apellido ?? userDoc['apellido'],
        'cedula': cedula ?? userDoc['cedula'],
        'tipo': tipoUsuario,
        'codigoGimnasio': codigoFinal,
        'talla': tipoUsuario == 'Cliente' ? talla : null,
        'peso': tipoUsuario == 'Cliente' ? peso : null,
        'membresia': tipoUsuario == 'Cliente' ? membresia : null,
        'pago': tipoUsuario == 'Cliente' ? pago : null,
        'habilitado': true,
        'estado': 'activo',
        'fechaUltimoPago':
            tipoUsuario == 'Cliente' ? FieldValue.serverTimestamp() : null,
      };

      // Actualizar en usuarios global
      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .update({'codigoGimnasio': codigoFinal, 'tipo': tipoUsuario});

      // Guardar en subcolección del gimnasio
      await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('usuarios')
          .doc(usuarioId)
          .set(userData);

      // Guardar en subcolección gimnasios dentro del usuario
      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('gimnasios')
          .doc(gimnasioId)
          .set({
        'nombreGimnasio': nombreGimnasio,
        'tipoUsuario': tipoUsuario,
        'codigoGimnasio': codigoFinal, // ← ahora sí correcto
        'Habilitado': true,
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

    try {
      final querySnapshot = await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('usuarios')
          .get();

      final usuarios = querySnapshot.docs
          .map((doc) => {'uid': doc.id, ...doc.data()})
          .toList();

      _errorMessage = null;
      _successMessage = 'Usuarios obtenidos correctamente';

      return usuarios;
    } catch (e) {
      _errorMessage = 'Error al obtener usuarios: $e';
      _successMessage = null;
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerPerson(UserRegisterModels usern) async {
    try {
      await _firestore.collection('usuarios').add(usern.toJson());
      debugPrint('Persona registrada correctamente');
    } catch (e) {
      debugPrint('Error al registrar persona: $e');
    }
  }
}
