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


  Future<void> manejarGuardarYActualizar({
    required String uid,
    required String codigo,
    required String tipoUsuario,
    String? nombreGimnasio,
    String? direccionGimnasio,
    String? telefonoGimnasio,
  }) async {
    
    _isLoading = true;
    notifyListeners();

    try {
      if (tipoUsuario == 'dueño') {
        if (nombreGimnasio == null ||
            direccionGimnasio == null ||
            telefonoGimnasio == null) {
          throw Exception('Faltan datos del gimnasio');
        }
        await _gimnasioService.crearGimnasio(
          uid: uid,
          nombre: nombreGimnasio,
          direccion: direccionGimnasio,
          telefono: telefonoGimnasio,
        );
      }

      bool codigoValido =
          await _gimnasioService.validarCodigoActivacion(codigo, uid);

      if (!codigoValido) {
        throw Exception('Código inválido o ya usado');
      }

      await _userService.updateUserGymCode(uid, codigo, tipoUsuario);

      _errorMessage = null;
      _successMessage = 'Datos guardados correctamente';
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

  Future<void> updateUserGymCode(String uid, String codigo, String tipoUsuario) async {
    try {
      await _userService.updateUserGymCode(uid, codigo, tipoUsuario);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al actualizar el codigo: $e');
    }
  }
}
