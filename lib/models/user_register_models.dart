class UserRegisterModels {
  final String? uid;
  final String cedula;
  final String nombre;
  final String apellido;
  final String direccion;
  final String tipo;
  final String tieneUsuario;
  final String? email;

  UserRegisterModels({
    this.uid,
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.direccion,
    required this.tipo,
    required this.tieneUsuario,
    this.email,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'cedula': cedula,
        'nombre': nombre,
        'apellido': apellido,
        'direccion': direccion,
        'tipo': tipo,
        'tieneUsuario': tieneUsuario,
        'email': email,
      };
}
