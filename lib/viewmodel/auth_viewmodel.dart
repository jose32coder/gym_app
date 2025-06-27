import 'package:basic_flutter/gymCodeOrSelect/selection_rol_page.dart';
import 'package:basic_flutter/login/sign_in.dart';
import 'package:basic_flutter/navigation_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

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

  Future<Map<String, dynamic>?> obtenerDatosUsuario(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
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

  Future<void> register({
    required String ced,
    required String email,
    required String password,
    required String name,
    required String lastname,
      required String? sexo
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
          ced: ced,
        email: email,
        name: name,
        lastname: lastname,
          sexo: sexo
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
    required String ced,
    required String uid,
    required String email,
    required String name,
    required String lastname,
    required String? sexo,
  }) async {
    await _firestore.collection('usuarios').doc(uid).set({
      'uid': uid,
      'cedula': ced,
      'email': email,
      'nombre': name,
      'apellido': lastname,
      'codigoGimnasio': '',
      'sexo': sexo
    });
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
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        // Usuario no autenticado
        return Stream.value(const SignIn());
      }

      // Usuario autenticado — escuchamos su documento
      final userGymsStream = _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('gimnasios')
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return const SelectionRolPage();
        }

        // Puedes tomar el primer gimnasio, o iterar si quieres
        final firstGymData = snapshot.docs.first.data();
        final codigo = firstGymData['codigoGimnasio'] as String?;

        if (codigo == null || codigo.isEmpty) {
          return const SelectionRolPage();
        }

        return const NavigationMenu();
      });

      return userGymsStream;
    });
  }
}
