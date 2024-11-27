class UserModel {
  final String id;
  final String nombre;
  final String correo;
  final String telefono;
  final String? foto;

  UserModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.foto,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nombre: json['nombre'],
      correo: json['correo'],
      telefono: json['telefono'],
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'foto': foto,
    };
  }
}