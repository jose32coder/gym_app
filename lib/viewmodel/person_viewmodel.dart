// import 'package:basic_flutter/services/gimnasio_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PersonasViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final _gimnasioService = GimnasioService();

  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> get usuarios => _usuarios;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _usuariosCargados = false;

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

  List<Map<String, dynamic>> get ultimosClientes {
    final sorted = List<Map<String, dynamic>>.from(usuarios);

    sorted.sort((a, b) {
      // Obtener fechaRegistro de a
      final fechaA = a['fechaRegistro'] is Timestamp
          ? (a['fechaRegistro'] as Timestamp).toDate()
          : DateTime(2000);

      // Obtener fechaRegistro de b
      final fechaB = b['fechaRegistro'] is Timestamp
          ? (b['fechaRegistro'] as Timestamp).toDate()
          : DateTime(2000);

      return fechaB.compareTo(fechaA);
    });

    return sorted.take(8).toList();
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
        notifyListeners();
        return;
      }

      usuarioActivoId = user.uid;

      final userDoc =
          await _firestore.collection('usuarios').doc(user.uid).get();

      if (!userDoc.exists || userDoc.data() == null) {
        _usuarios = [];
        rolUsuario = null;
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
      if (codigoCorto.isEmpty) {
        throw Exception('Código de gimnasio inválido');
      }

      final gimnasioQuery = await _firestore
          .collection('gimnasios')
          .where('codigo', isEqualTo: codigoCorto)
          .limit(1)
          .get();

      if (gimnasioQuery.docs.isEmpty) {
        throw Exception('Gimnasio con código $codigoCorto no encontrado');
      }

      final gimnasioId = gimnasioQuery.docs.first.id;

      switch (rolUsuario) {
        case 'Administrador':
        case 'Dueño':
          _usuarios = await obtenerUsuariosDeGimnasio(gimnasioId);
          break;
        default:
          _usuarios = [];
      }
    } catch (e) {
      _errorMessage = 'Error al cargar usuarios: $e';
      _usuarios = [];
      debugPrint('[cargarUsuarios] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarUsuariosSiNecesario() async {
    if (_usuariosCargados) return; // ya cargado, no hacer nada
    await cargarUsuarios();
    _usuariosCargados = true;
  }

  Future<void> recargarUsuarios() async {
    _usuariosCargados = false;
    await cargarUsuarios();
    _usuariosCargados = true;
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

  Future<Map<String, dynamic>?> obtenerDocumentoEnSubcoleccion({
    required String coleccionPadre,
    required String? docPadreId,
    required String subcoleccion,
    required String docHijoId,
  }) async {
    try {
      final ref = _firestore
          .collection(coleccionPadre)
          .doc(docPadreId)
          .collection(subcoleccion)
          .doc(docHijoId);

      final snapshot = await ref.get();

      if (snapshot.exists) {
        return snapshot.data();
      } else {
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error al obtener documento en subcolección.';
      rethrow;
    }
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
        'fechaRegistro': FieldValue.serverTimestamp()
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

      // Obtén token solo si es Administrador
      String? fcmToken;
      if (tipoUsuario == 'Administrador') {
        fcmToken = await FirebaseMessaging.instance.getToken();
      }

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
        'estado': 'pendiente',
        'fechaUltimoPago':
            tipoUsuario == 'Cliente' ? FieldValue.serverTimestamp() : null,
        'fechaRegistro': FieldValue.serverTimestamp(),
        // Solo guarda token si aplica
        if (fcmToken != null) 'token': fcmToken,
      };

      // Guarda en gimnasio/usuarios
      await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('usuarios')
          .doc(usuarioId)
          .set(asociacionData);

      // También guarda referencia en usuarios/gimnasios
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

  Future<List<Map<String, dynamic>>> obtenerUsuariosConEstado() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    final user = auth.currentUser;
    if (user == null) return [];

    // Obtener datos del usuario actual
    final userDoc = await firestore.collection('usuarios').doc(user.uid).get();
    final userData = userDoc.data();
    if (userData == null || userData['codigoGimnasio'] == null) return [];

    // Extraer el código del gimnasio (corto)
    final codigoGimnasio = userData['codigoGimnasio'];
    final codigoCorto = codigoGimnasio.length >= 8
        ? codigoGimnasio.substring(0, 8)
        : codigoGimnasio;

    // Buscar el gimnasio en base al código
    final gimnasioQuery = await firestore
        .collection('gimnasios')
        .where('codigo', isEqualTo: codigoCorto)
        .limit(1)
        .get();

    if (gimnasioQuery.docs.isEmpty) return [];

    final gimnasioId = gimnasioQuery.docs.first.id;

    // Buscar usuarios dentro del gimnasio, solo tipo "Cliente"
    final usuariosSnapshot = await firestore
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('usuarios')
        .where('tipo', isEqualTo: 'Cliente')
        .get();

    // Retornar los campos necesarios
    return usuariosSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'cedula': data['cedula'] ?? '',
        'nombre': data['nombre'] ?? '',
        'apellido': data['apellido'] ?? '',
        'membresia': data['membresia'] ?? '',
        'estado': data['estado'] ?? '',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> buscarUsuariosPorCedulaEnGimnasio(
      String gimnasioId, String cedulaBusqueda) async {
    try {
      final querySnapshot = await _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('usuarios')
          .where('cedula', isGreaterThanOrEqualTo: cedulaBusqueda)
          .where('cedula', isLessThanOrEqualTo: '$cedulaBusqueda\uf8ff')
          // .where('tipo', isEqualTo: 'Cliente') // Comentado para test
          .get();

      return querySnapshot.docs
          .map((doc) => {'uid': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> actualizarDatosUsuario({
    required String usuarioId,
    String? gimnasioId,
    required Map<String, dynamic> datosCompletos,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (usuarioId.isEmpty) {
      _errorMessage = 'ID de usuario o gimnasio no proporcionado.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final Map<String, dynamic> datosActualizados = {
        'nombre': datosCompletos['nombre'] ?? 'Sin nombre',
        'apellido': datosCompletos['apellido'] ?? 'Sin apellido',
        'cedula': datosCompletos['cedula'] ?? '',
        'telefono': datosCompletos['telefono'] ?? '',
      };

      final Map<String, dynamic> datosGimnasio = {
        'nombre': datosActualizados['nombre'],
        'apellido': datosActualizados['apellido'],
        'cedula': datosActualizados['cedula'],
        'telefono': datosActualizados['telefono'],
      };

      final batch = _firestore.batch();

      final usuarioRef = _firestore.collection('usuarios').doc(usuarioId);
      batch.set(usuarioRef, datosActualizados, SetOptions(merge: true));

      final usuarioGimnasioRef = _firestore
          .collection('gimnasios')
          .doc(gimnasioId)
          .collection('usuarios')
          .doc(usuarioId);
      batch.set(usuarioGimnasioRef, datosGimnasio, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      _errorMessage = 'Error al actualizar datos del usuario.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
