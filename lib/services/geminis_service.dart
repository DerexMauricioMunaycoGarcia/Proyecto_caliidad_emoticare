import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey =
      "AQ.Ab8RN6IS998ilGSPqSJMHwJ-3iTX0SvsIpou8Y_dbdCMaH9rIw";
  static const String _model = "gemini-2.5-flash";
  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent";

  static Future<String> sendMessage(String userText) async {
    final uri = Uri.parse("$_baseUrl?key=$_apiKey");

    final prompt = """
Eres EmotiCare, asistente emocional empático y útil. Responde SIEMPRE en español.

REGLA PRINCIPAL: Lee con atención lo que pide el usuario y respóndele EXACTAMENTE eso.
- Si pide consejos → da consejos concretos y útiles (mínimo 3).
- Si saluda → saluda de vuelta con calidez.
- Si expresa una emoción → valídala y ofrece apoyo.
- Si hace una pregunta → respóndela directamente.

FORMATO: Respuestas de 3 a 6 oraciones. Si das consejos, usa lista numerada.
Sé cálido, humano y directo. Nunca ignores lo que pide el usuario.

Usuario dice: "$userText"
""";

    try {
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": prompt},
                  ],
                },
              ],
              "generationConfig": {"maxOutputTokens": 450, "temperature": 0.75},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
        return text?.trim() ?? "No obtuve respuesta, intenta de nuevo.";
      } else {
        final body = jsonDecode(response.body);
        return "Error ${response.statusCode}: ${body["error"]?["message"] ?? "desconocido"}";
      }
    } catch (e) {
      return "Error de conexión: $e";
    }
  }
}
