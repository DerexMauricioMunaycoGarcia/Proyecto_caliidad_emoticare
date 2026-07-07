// lib/services/evaluation_storage_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter_ia/services/evaluacion.dart';

class EvaluationStorageService {
  static final CollectionReference<Map<String, dynamic>> _evaluaciones =
      FirebaseFirestore.instance.collection('evaluaciones');

  /// Devuelve todas las evaluaciones, más recientes primero.
  static Future<List<Evaluacion>> obtenerEvaluaciones() async {
    final snapshot =
        await _evaluaciones.orderBy('fecha', descending: true).get();
    return snapshot.docs.map((d) => Evaluacion.fromFirestore(d)).toList();
  }

  /// Guarda una nueva evaluación.
  static Future<void> guardarEvaluacion(Evaluacion evaluacion) async {
    await _evaluaciones.add(evaluacion.toFirestore());
  }

  /// Borra todas las evaluaciones (útil para pruebas/reset).
  static Future<void> limpiarEvaluaciones() async {
    final snapshot = await _evaluaciones.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
