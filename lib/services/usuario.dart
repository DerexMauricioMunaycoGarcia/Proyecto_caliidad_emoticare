// lib/models/usuario.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String nombre;
  final String apellido;
  final int edad;
  final String rol;
  final String email;
  final String password;

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

  factory Usuario.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Usuario.fromJson(doc.data()!);
  }

  String get nombreCompleto => '$nombre $apellido';
}
