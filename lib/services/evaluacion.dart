// lib/services/evaluacion.dart

/// Modelo que representa el resultado de una evaluación emocional
/// completada por un estudiante.
class Evaluacion {
  final String nombre;
  final DateTime fecha;
  final String texto;
  final List<String> respuestas; // 5 respuestas del cuestionario
  final String sentimiento; // "positivo" | "negativo" | "neutral"
  final String riesgo; // "muy_alto" | "alto" | "medio" | "bajo" | "muy_bajo"
  final String recomendacion;

  Evaluacion({
    required this.nombre,
    required this.fecha,
    required this.texto,
    required this.respuestas,
    required this.sentimiento,
    required this.riesgo,
    required this.recomendacion,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'fecha': fecha.toIso8601String(),
    'texto': texto,
    'respuestas': respuestas,
    'sentimiento': sentimiento,
    'riesgo': riesgo,
    'recomendacion': recomendacion,
  };

  factory Evaluacion.fromJson(Map<String, dynamic> json) {
    return Evaluacion(
      nombre: json['nombre'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      texto: json['texto'] as String,
      respuestas: List<String>.from(json['respuestas'] as List),
      sentimiento: json['sentimiento'] as String,
      riesgo: json['riesgo'] as String,
      recomendacion: json['recomendacion'] as String,
    );
  }

  String get fechaFormateada {
    final d = fecha;
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    return "${dosDigitos(d.day)}/${dosDigitos(d.month)}/${d.year} "
        "${dosDigitos(d.hour)}:${dosDigitos(d.minute)}";
  }

  /// Agrupa "alto" y "muy_alto" como un solo nivel para las estadísticas.
  String get riesgoAgrupado {
    if (riesgo == 'alto' || riesgo == 'muy_alto') return 'alto';
    if (riesgo == 'bajo' || riesgo == 'muy_bajo') return 'bajo';
    return 'medio';
  }
}