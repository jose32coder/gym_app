import 'package:basic_flutter/gymCodeOrSelect/selection_rol_page.dart';
import 'package:basic_flutter/layouts/client/client_homepage.dart';
import 'package:basic_flutter/login/sign_in.dart';
import 'package:basic_flutter/layouts/navigation_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

  Future<void> register(
      {required String ced,
      required String email,
      required String password,
      required String name,
      required String lastname}) async {
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
  }) async {
    await _firestore.collection('usuarios').doc(uid).set({
      'uid': uid,
      'cedula': ced,
      'email': email,
      'nombre': name,
      'apellido': lastname,
      'codigoGimnasio': '',
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

      // Obtener token FCM
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        // Guardar token en Firestore en el documento del usuario
        await _firestore
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .update({'fcmToken': fcmToken});
      }

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


  Future<void> deleteAccountTotal() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    try {
      // Primero elimina el usuario de Authentication
      await user.delete();

      // Luego elimina los documentos de Firestore
      final userId = user.uid;
      await _firestore.collection('usuarios').doc(userId).delete();
    } on FirebaseAuthException catch (e) {
      // Aquí puedes manejar error, como sesión no reciente (requiere re-login)
      throw Exception('Error al eliminar usuario: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<Widget> get userScreenStream {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream.value(const SignIn());
      }

      final userDocStream =
          _firestore.collection('usuarios').doc(user.uid).snapshots();

      return userDocStream.map((doc) {
        if (!doc.exists) {
          return const SelectionRolPage();
        }

        final data = doc.data()!;
        final rol = data['tipo'] as String?;
        final codigoGimnasio = data['codigoGimnasio'] as String?;
        final nombre = data['nombre'] as String?;

        if (rol == null) {
          return const SelectionRolPage();
        }

        if (rol == 'Cliente') {
          return ClienteHomePage(user: user);
        }

        // Para administradores o dueños, validamos el código
        if (codigoGimnasio == null || codigoGimnasio.isEmpty) {
          return const SelectionRolPage();
        }

        return NavigationMenu(nombreUsuario: nombre);
      });
    });
  }
}
