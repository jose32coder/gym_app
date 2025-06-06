import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<void> updateUserGymCode(String uid, String codigo, String tipoUsuario) async {
    await _db.collection('usuarios').doc(uid).update({
      'codigo': codigo,
      'tipoUsuario': tipoUsuario,
    });
  }
}
