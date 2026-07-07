// lib/services/evaluacion.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Evaluacion {
  final String?
  id; // ID del documento en Firestore (útil para futuras ediciones/borrados)
  final String nombre;
  final DateTime fecha;
  final String texto;
  final List<String> respuestas;
  final String sentimiento;
  final String riesgo;
  final String recomendacion;

  Evaluacion({
    this.id,
    required this.nombre,
    required this.fecha,
    required this.texto,
    required this.respuestas,
    required this.sentimiento,
    required this.riesgo,
    required this.recomendacion,
  });

  Map<String, dynamic> toFirestore() => {
    'nombre': nombre,
    'fecha': Timestamp.fromDate(fecha),
    'texto': texto,
    'respuestas': respuestas,
    'sentimiento': sentimiento,
    'riesgo': riesgo,
    'recomendacion': recomendacion,
  };

  factory Evaluacion.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Evaluacion(
      id: doc.id,
      nombre: data['nombre'] as String,
      fecha: (data['fecha'] as Timestamp).toDate(),
      texto: data['texto'] as String,
      respuestas: List<String>.from(data['respuestas'] as List),
      sentimiento: data['sentimiento'] as String,
      riesgo: data['riesgo'] as String,
      recomendacion: data['recomendacion'] as String,
    );
  }

  String get fechaFormateada {
    final d = fecha;
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    return "${dosDigitos(d.day)}/${dosDigitos(d.month)}/${d.year} "
        "${dosDigitos(d.hour)}:${dosDigitos(d.minute)}";
  }

  String get riesgoAgrupado {
    if (riesgo == 'alto' || riesgo == 'muy_alto') return 'alto';
    if (riesgo == 'bajo' || riesgo == 'muy_bajo') return 'bajo';
    return 'medio';
  }
}
