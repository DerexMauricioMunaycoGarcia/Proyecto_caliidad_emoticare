// lib/services/evaluation_storage_service.dart

import 'dart:convert';
import 'package:proyecto_flutter_ia/services/evaluacion.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Maneja el registro y consulta de evaluaciones emocionales
/// guardadas localmente usando SharedPreferences.
class EvaluationStorageService {
  static const String _key = 'evaluaciones_guardadas';

  /// Devuelve todas las evaluaciones guardadas, más recientes primero.
  static Future<List<Evaluacion>> obtenerEvaluaciones() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null || data.isEmpty) return [];

    final List decoded = jsonDecode(data);
    final lista = decoded
        .map((e) => Evaluacion.fromJson(e as Map<String, dynamic>))
        .toList();

    lista.sort((a, b) => b.fecha.compareTo(a.fecha)); // más reciente primero
    return lista;
  }

  /// Guarda una nueva evaluación en la lista persistida.
  static Future<void> guardarEvaluacion(Evaluacion evaluacion) async {
    final evaluaciones = await obtenerEvaluaciones();
    evaluaciones.add(evaluacion);

    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(evaluaciones.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }

  /// Borra todas las evaluaciones (útil para pruebas/reset).
  static Future<void> limpiarEvaluaciones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}