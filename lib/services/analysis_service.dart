class AnalysisService {
  static String analizarSentimiento(String texto) {
    if (texto.trim().isEmpty) return "neutral";

    texto = texto.toLowerCase();
    final positivas = [
      "feliz",
      "motivado",
      "contento",
      "bien",
      "alegre",
      "tranquilo",
      "positivo",
      "optimista",
      "emocionado",
    ];
    final negativas = [
      "triste",
      "solo",
      "desmotivado",
      "mal",
      "cansado",
      "estresado",
      "deprimido",
      "ansioso",
      "preocupado",
      "vacío",
      "enojado",
    ];

    final pos = positivas.where((p) => texto.contains(p)).length;
    final neg = negativas.where((n) => texto.contains(n)).length;

    if (pos > neg) return "positivo";
    if (neg > pos) return "negativo";
    return "neutral";
  }

  static String calcularNivelRiesgo(List<String?> respuestas) {
    int puntaje = 0;
    for (var r in respuestas) {
      switch (r) {
        case "Nunca":
          puntaje += 1;
          break;
        case "A veces":
          puntaje += 2;
          break;
        case "Frecuentemente":
          puntaje += 3;
          break;
        case "Siempre":
          puntaje += 4;
          break;
      }
    }
    if (puntaje >= 17) return "muy_alto";
    if (puntaje >= 13) return "alto";
    if (puntaje >= 9) return "medio";
    if (puntaje >= 5) return "bajo";
    return "muy_bajo";
  }

  static String generarRecomendacion(String nivelRiesgo, String sentimiento) {
    switch (nivelRiesgo) {
      case "muy_alto":
        return "🔴 ¡Es importante que busques ayuda! Habla con tu docente o tutor de confianza de inmediato.";
      case "alto":
        return sentimiento == "negativo"
            ? "🔶 Te recomendamos hablar con alguien de confianza para recibir apoyo emocional."
            : "🟠 Realizaremos un seguimiento cada quince días para fortalecer tu bienestar emocional.";
      case "medio":
        return sentimiento == "negativo"
            ? "🟡 Practica ejercicios de autocuidado y conversa con tu tutor para apoyarte."
            : "🟢 ¡Sigue así! Mantén tus hábitos positivos y busca tiempo para ti.";
      case "bajo":
        return sentimiento == "negativo"
            ? "🟠 Fortalece tus lazos con amigos y familiares."
            : "🟢 Mantén tus emociones estables y continúa con tu actitud positiva.";
      case "muy_bajo":
        return sentimiento == "positivo"
            ? "🟢 ¡Excelente! Tu estado emocional es óptimo, sigue fomentando tu liderazgo."
            : "🟡 Todo está estable, sigue cuidando tu bienestar emocional.";
      default:
        return "⚠️ No se pudo determinar una recomendación precisa. Intenta responder nuevamente.";
    }
  }
}
