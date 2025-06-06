import 'package:basic_flutter/gymCodeOrSelect/selection_rol_page.dart';
import 'package:basic_flutter/login/sign_in.dart';
import 'package:basic_flutter/navigation_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthViewmodel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _userName;
  String? _userEmail;
  String? _tempName;
  String? _tempLastname;
  String? _tempEmail;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get tempName => _tempName;
  String? get tempLastname => _tempLastname;
  String? get tempEmail => _tempEmail;

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String lastname,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      _tempName = name;
      _tempLastname = lastname;
      _tempEmail = email;

      await saveBasicUserData(
        uid: cred.user!.uid,
        email: email,
        name: name,
        lastname: lastname,
      );

      _errorMessage = null;
      _successMessage = 'Usuario registrado correctamente';
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _successMessage = null;
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado';
      _successMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveBasicUserData({
    required String uid,
    required String email,
    required String name,
    required String lastname,
  }) async {
    await _firestore.collection('usuarios').doc(uid).set({
      'uid': uid,
      'email': email,
      'nombre': name,
      'apellido': lastname,
      'codigo': '', // vacío al inicio
    });
  }

  Future<void> saveUserDataToFirestore({
    required String uid,
    required String cedula,
    required String direccion,
    required String tipo,
    required String tieneUsuario,
    required String codigoGimnasio,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore
          .collection('usuarios')
          .doc(codigoGimnasio)
          .collection('usuarios')
          .doc(uid)
          .set({
        'uid': uid,
        'nombre': _tempName ?? '',
        'apellido': _tempLastname ?? '',
        'email': _tempEmail ?? '',
        'cedula': cedula,
        'direccion': direccion,
        'tipo': tipo,
        'tieneUsuario': tieneUsuario,
        'codigoGimnasio': codigoGimnasio,
      });

      _errorMessage = null;
      _successMessage = 'Datos guardados correctamente';
    } catch (e) {
      _errorMessage = 'Error al guardar datos: $e';
      _successMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        _userName = userDoc['name'] ?? 'Usuario';
        _userEmail = userDoc['email'] ?? email;
      } else {
        _userName = 'Usuario';
        _userEmail = email;
      }

      _errorMessage = null;
      _successMessage = 'Login exitoso';
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _successMessage = null;
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado';
      _successMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<Widget> get userScreenStream {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        // Usuario no autenticado: muestra pantalla de login
        return Stream.value(const SignIn());
      }

      // Usuario autenticado: escucha el documento del perfil en Firestore
      return _firestore
          .collection('usuarios')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
        if (!doc.exists) {
          // No existe documento de perfil: puedes regresar a SignIn
          // o a una pantalla para crear perfil si prefieres
          return const SignIn();
        }

        final data = doc.data()!;
        final codigo = data['codigo'] as String?;

        if (codigo == null || codigo.isEmpty) {
          // El usuario está autenticado pero no tiene rol asignado
          return const SelectionRolPage();
        }

        // El usuario tiene rol asignado: navega a menú principal
        return const NavigationMenu();
      });
    });
  }
}
