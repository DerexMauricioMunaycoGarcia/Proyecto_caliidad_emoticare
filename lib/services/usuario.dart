// lib/models/usuario.dart

/// Modelo que representa a un usuario registrado en la app
/// (puede ser Estudiante o Docente).
class Usuario {
  final String nombre;
  final String apellido;
  final int edad;
  final String rol; // "Estudiante" o "Docente"
  final String email; // Generado automáticamente: Nombre.Rol@gmail.com
  final String password; // Contraseña creada por el usuario

  Usuario({
    required this.nombre,
    required this.apellido,
    required this.edad,
    required this.rol,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'apellido': apellido,
    'edad': edad,
    'rol': rol,
    'email': email,
    'password': password,
  };

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      edad: json['edad'] as int,
      rol: json['rol'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}