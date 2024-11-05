class UserModel {
  final String nombre;
  final String correo;
  final String contrasena;
  final String telefono;

  UserModel({required this.nombre, required this.correo, required this.contrasena, required this.telefono} );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      contrasena: json['contrasena'] as String,
      telefono:  json['telefono'] as String
    );
  }
}
