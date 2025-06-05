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

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  Future<void> register({
  required String email,
  required String password,
  required String name,
  required String lastname,
  required String cedula,
  required String direccion,
  String tipo = 'cliente',
}) async {
  _isLoading = true;
  notifyListeners();

  try {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    await _firestore.collection('usuarios').doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'email': email,
      'nombre': name,
      'apellido': lastname,
      'cedula': cedula,
      'direccion': direccion,
      'tipo': tipo,
      'tieneUsuario': 'si',
    });

    _userName = name;
    _userEmail = email;
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
        _userEmail = userDoc['email'] ??
            email; // asigna el email desde Firestore o fallback
      } else {
        _userName = 'Usuario';
        _userEmail = email; // fallback por si no hay doc en Firestore
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
}
