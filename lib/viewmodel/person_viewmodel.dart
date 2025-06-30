import 'package:basic_flutter/services/gimnasio_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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

  String? gimnasioId;
  late String codigo;

  // Helper para obtener los primeros 8 caracteres con validación
  String _codigoGimnasioCorto(String codigo) {
    if (codigo.isEmpty) throw Exception('Código de gimnasio vacío');
    return codigo.length >= 8 ? codigo.substring(0, 8) : codigo;
  }

  Future<String?> obtenerGimnasioIdUsuario() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _firestore.collection('usuarios').doc(user.uid).get();

    if (!userDoc.exists || userDoc.data() == null) return null;

    final data = userDoc.data()!;
    final codigoGimnasioUsuario = data['codigoGimnasio'] ?? '';

    if (codigoGimnasioUsuario.isEmpty) return null;

    // Aquí extraemos los primeros 8 caracteres
    final codigoCorto = codigoGimnasioUsuario.length >= 8
        ? codigoGimnasioUsuario.substring(0, 8)
        : codigoGimnasioUsuario;

    final gimnasioQuery = await _firestore
        .collection('gimnasios')
        .where('codigo', isEqualTo: codigoCorto)
        .limit(1)
        .get();

    if (gimnasioQuery.docs.isEmpty) return null;

    return gimnasioQuery.docs.first.id;
  }

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
        _isLoading = false;
        notifyListeners();
        return;
      }

      usuarioActivoId = user.uid;

      final userDoc =
          await _firestore.collection('usuarios').doc(user.uid).get();

      if (!userDoc.exists || userDoc.data() == null) {
        _usuarios = [];
        rolUsuario = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final data = userDoc.data()!;
      rolUsuario = data['tipo'] as String? ?? '';

      final codigoGimnasioUsuario = data['codigoGimnasio'] ?? '';

      if (codigoGimnasioUsuario.isEmpty) {
        throw Exception('El usuario no tiene código de gimnasio asignado');
      }

      final codigoCorto = _codigoGimnasioCorto(codigoGimnasioUsuario);

      final gimnasioQuery = await _firestore
          .collection('gimnasios')
          .where('codigo', isEqualTo: codigoCorto)
          .limit(1)
          .get();

      if (gimnasioQuery.docs.isEmpty) {
        throw Exception('Gimnasio con código $codigoCorto no encontrado');
      }

      final gimnasioDoc = gimnasioQuery.docs.first;
      final gimnasioId = gimnasioDoc.id;

      if (rolUsuario == 'Cliente') {
        _usuarios = [];
      } else if (rolUsuario == 'Administrador' || rolUsuario == 'Dueño') {
        _usuarios = await obtenerUsuariosDeGimnasio(gimnasioId);
      } else {
        _usuarios = [];
      }
    } catch (e) {
      _errorMessage = 'Error al cargar usuarios: $e';
      _usuarios = [];
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
        .where('tipo', isEqualTo: 'Cliente')
        .get();

    return querySnapshot.docs
        .map((doc) => {'uid': doc.id, ...doc.data()})
        .toList();
  }

  Future<String> registerNewUserFromAdmin({
    required String email,
    required String password,
    required String name,
    required String lastname,
    required String cedula,
    required String? sexo,
    required String? codeGym,
    required String? tipo,
  }) async {
    try {
      FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      UserCredential userCredential =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String newUid = userCredential.user!.uid;

      await _firestore.collection('usuarios').doc(newUid).set({
        'uid': newUid,
        'cedula': cedula,
        'email': email,
        'nombre': name,
        'apellido': lastname,
        'codigoGimnasio': codeGym,
        'sexo': sexo,
        'tipo': tipo,
      });

      await secondaryAuth.signOut();
      await secondaryApp.delete();

      return newUid;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> asociarUsuarioAGimnasioPorCodigo({
    required String usuarioId,
    required String? tipoUsuario,
    String? talla,
    String? peso,
    String? membresia,
    String? pago,
    String? codeGym,
  }) async {
    try {
      final userDoc =
          await _firestore.collection('usuarios').doc(usuarioId).get();
      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado');
      }

      final userData = userDoc.data()!;
      final codigoGimnasioUsuario = userData['codigoGimnasio'] ?? '';

      if (codigoGimnasioUsuario.isEmpty) {
        throw Exception('El usuario no tiene código de gimnasio asignado');
      }

      final codigoCorto = _codigoGimnasioCorto(codigoGimnasioUsuario);

      final gimnasioQuery = await _firestore
          .collection('gimnasios')
          .where('codigo', isEqualTo: codigoCorto)
          .limit(1)
          .get();

      if (gimnasioQuery.docs.isEmpty) {
        throw Exception('Gimnasio con código $codigoCorto no encontrado');
      }

      final gimnasioDoc = gimnasioQuery.docs.first;
      final gimnasioId = gimnasioDoc.id;
      final nombreGimnasio = gimnasioDoc.data()['nombre'] ?? 'Sin nombre';

      final nombre = userData['nombre'] ?? 'Sin nombre';
      final apellido = userData['apellido'] ?? 'Sin apellido';
      final cedula = userData['cedula'] ?? 'Sin cédula';

      final asociacionData = {
        'uid': usuarioId,
        'nombre': nombre,
        'apellido': apellido,
        'cedula': cedula,
        'tipo': tipoUsuario,
        'codigoGimnasio': codigoGimnasioUsuario,
        'talla': tipoUsuario == 'Cliente' ? talla : '',
        'peso': tipoUsuario == 'Cliente' ? peso : '',
        'membresia': tipoUsuario == 'Cliente' ? membresia : '',
        'pago': tipoUsuario == 'Cliente' ? pago : '',
        'habilitado': true,
        'estado': 'activo',
        'fechaUltimoPago':
            tipoUsuario == 'Cliente' ? FieldValue.serverTimestamp() : null,
      };

      await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('usuarios')
          .doc(usuarioId)
          .set(asociacionData);

      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('gimnasios')
          .doc(gimnasioId)
          .set({
        'nombreGimnasio': nombreGimnasio,
        'tipoUsuario': tipoUsuario,
        'codigoGimnasio': codigoGimnasioUsuario,
        'habilitado': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> buscarUsuariosPorCedulaEnGimnasio(
      String gimnasioId, String cedulaBusqueda) async {
    try {
      final querySnapshot = await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('usuarios')
          .where('cedula', isGreaterThanOrEqualTo: cedulaBusqueda)
          .where('cedula', isLessThanOrEqualTo: cedulaBusqueda + '\uf8ff')
          // .where('tipo', isEqualTo: 'Cliente') // Comentado para test
          .get();

      return querySnapshot.docs
          .map((doc) => {'uid': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      return [];
    }
  }
}
