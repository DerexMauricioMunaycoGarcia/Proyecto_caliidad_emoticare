// lib/services/user_storage_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter_ia/services/usuario.dart';

class UserStorageService {
  static final CollectionReference<Map<String, dynamic>> _usuarios =
      FirebaseFirestore.instance.collection('usuarios');

  static String _docId(String email) => email.toLowerCase();

  /// Devuelve todos los usuarios registrados.
  static Future<List<Usuario>> obtenerUsuarios() async {
    final snapshot = await _usuarios.get();
    return snapshot.docs.map((d) => Usuario.fromFirestore(d)).toList();
  }

  /// Verifica si ya existe un usuario con ese correo.
  static Future<bool> emailExiste(String email) async {
    final doc = await _usuarios.doc(_docId(email)).get();
    return doc.exists;
  }

  /// Guarda un nuevo usuario.
  static Future<void> guardarUsuario(Usuario usuario) async {
    await _usuarios.doc(_docId(usuario.email)).set(usuario.toJson());
  }

  /// Busca un usuario por su correo. Devuelve null si no existe.
  static Future<Usuario?> buscarPorEmail(String email) async {
    final doc = await _usuarios.doc(_docId(email)).get();
    if (!doc.exists) return null;
    return Usuario.fromFirestore(doc);
  }

  /// Valida correo + contraseña.
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
