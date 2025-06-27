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
      codigo = await _gimnasioService.obtenerCodigoGimnasio(gimnasioId!);

      print('Código gimnasio: $codigo');

      if (rolUsuario == 'Cliente') {
        _usuarios = [];
      } else if (rolUsuario == 'Administrador' || rolUsuario == 'Dueño') {
        _usuarios = await obtenerUsuariosDeGimnasio(gimnasioId!);
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

      return newUid; // 👈 retornas el UID creado
    } catch (e) {
      print('Error al registrar usuario desde admin: $e');
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
      // Obtienes el documento del usuario
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

      // Buscas el gimnasio cuyo código coincida con los 8 primeros caracteres
      final gimnasioQuery = await _firestore
          .collection('gimnasios')
          .where('codigo', isEqualTo: codigoGimnasioUsuario.substring(0, 8))
          .limit(1)
          .get();

      if (gimnasioQuery.docs.isEmpty) {
        throw Exception(
            'Gimnasio con código ${codigoGimnasioUsuario.substring(0, 8)} no encontrado');
      }

      final gimnasioDoc = gimnasioQuery.docs.first;
      final gimnasioId = gimnasioDoc.id;
      final nombreGimnasio = gimnasioDoc.data()['nombre'] ?? 'Sin nombre';

      // Preparas los datos a guardar
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

      // Guardas en gimnasios/{gimnasioId}/usuarios/{usuarioId}
      await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('usuarios')
          .doc(usuarioId)
          .set(asociacionData);

      // Guardas en usuarios/{usuarioId}/gimnasios/{gimnasioId}
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

      print(
          'Asociación de usuario $usuarioId con gimnasio $gimnasioId completada.');
    } catch (e) {
      print('Error en asociarUsuarioAGimnasioPorCodigo: $e');
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
          .get();

      return querySnapshot.docs
          .map((doc) => {'uid': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error buscando usuarios por cédula: $e');
      return [];
    }
  }

}
