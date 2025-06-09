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

  Future<bool> validarCodigoActivacion(String codigo, String uid) async {
    return await _gimnasioService.validarCodigoActivacion(codigo, uid);
  }

  Future<void> marcarCodigoComoUsado(String codigo, String uid) async {
    await _gimnasioService.marcarCodigoComoUsado(codigo, uid);
  }

  Future<void> crearGimnasioConCodigo({
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

      await _gimnasioService.crearGimnasio(
        docID: nombreGimnasio,
        nombre: nombreGimnasio,
        direccion: direccionGimnasio,
        telefono: telefonoGimnasio,
        propietarioUid: uid,
        codigo: codigo,
      );

      await _userService.updateUserGymCode(uid, codigo, 'Dueño');

      _errorMessage = null;
      _successMessage = 'Gimnasio creado correctamente';
    } catch (e) {
      _errorMessage = e.toString();
      _successMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registrarUsuarioEnGimnasio({
    required String uid,
    required String tipoUsuario, // 'Cliente' o 'Administrador'
    required String gimnasioId,
    String? nombre,
    String? apellido,
    double? talla,
    double? peso,
    String? membresia,
    double? pago,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _gimnasioService.registrarUsuarioEnGimnasio(
        gimnasioId: gimnasioId,
        usuarioId: uid,
        tipoUsuario: tipoUsuario,
        nombre: nombre,
        apellido: apellido,
        talla: tipoUsuario == 'Cliente' ? talla : null,
        peso: tipoUsuario == 'Cliente' ? peso : null,
        membresia: tipoUsuario == 'Cliente' ? membresia : null,
        pago: tipoUsuario == 'Cliente' ? pago : null,
      );
      await _userService.updateUserGymCode(uid, gimnasioId, tipoUsuario);

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

  Future<void> registerPerson(UserRegisterModels usern) async {
    try {
      await _firestore.collection('usuarios').add(usern.toJson());
      debugPrint('Persona registrada correctamente');
    } catch (e) {
      debugPrint('Error al registrar persona: $e');
    }
  }
}
