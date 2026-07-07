// lib/services/user_storage_service.dart

import 'dart:convert';
import 'package:proyecto_flutter_ia/services/usuario.dart';
import 'package:proyecto_flutter_ia/services/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
/// Maneja el registro y consulta de usuarios guardados localmente
/// usando SharedPreferences (persisten entre sesiones de la app).
class UserStorageService {
  static const String _key = 'usuarios_registrados';
  
  

  /// Devuelve todos los usuarios registrados.
  static Future<List<Usuario>> obtenerUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null || data.isEmpty) return [];

    final List decoded = jsonDecode(data);
    return decoded
        .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Verifica si ya existe un usuario con ese correo (no distingue mayúsculas).
  static Future<bool> emailExiste(String email) async {
    final usuarios = await obtenerUsuarios();
    return usuarios.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
  }

  /// Guarda un nuevo usuario en la lista persistida.
  static Future<void> guardarUsuario(Usuario usuario) async {
    final usuarios = await obtenerUsuarios();
    usuarios.add(usuario);

    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(usuarios.map((u) => u.toJson()).toList());
    await prefs.setString(_key, data);
  }

  /// Busca un usuario por su correo. Devuelve null si no existe.
  static Future<Usuario?> buscarPorEmail(String email) async {
    final usuarios = await obtenerUsuarios();
    for (final u in usuarios) {
      if (u.email.toLowerCase() == email.toLowerCase()) return u;
    }
    return null;
  }

  /// Valida correo + contraseña contra los usuarios registrados.
  /// Devuelve el Usuario si las credenciales son correctas, o null si no.
  static Future<Usuario?> validarCredenciales(
    String email,
    String password,
  ) async {
    final usuario = await buscarPorEmail(email);
    if (usuario != null && usuario.password == password) {
      return usuario;
    }
    return null;
  }
}