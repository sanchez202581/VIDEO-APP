import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL base para la API de OpenAI (para GPT-4 Turbo)
  static const String _baseUrl = 'https://api.openai.com/v1';
  // Deberás configurar tu propia clave de API
  static const String _apiKey = 'TU_API_KEY_AQUI';

  // Método para generar narración reflexiva basada en descripción de video
  static Future<String> generateNarration(String videoDescription) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'Eres un narrador reflexivo con un estilo similar a Farid Dieck. '
                  'Crea una narración inspiradora y profunda basada en la descripción de video proporcionada. '
                  'La narración debe ser emotiva, filosófica y transmitir un mensaje positivo. '
                  'Usa un lenguaje claro pero profundo. No excedas los 3 párrafos.'
            },
            {
              'role': 'user',
              'content': 'Crea una narración reflexiva para un video con esta descripción: $videoDescription'
            }
          ],
          'temperature': 0.7,
          'max_tokens': 500
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Error al generar narración: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Método para analizar el contenido de un video (simulado)
  // En un entorno real, esto se conectaría a una API de análisis de video
  static Future<String> analyzeVideoContent(String videoPath) async {
    // Simulación de análisis de video
    // En un entorno real, enviarías el video a una API como Google Cloud Video Intelligence
    await Future.delayed(const Duration(seconds: 2));
    
    return 'Este video muestra escenas de la naturaleza con montañas, ríos y bosques. '
        'Se observan personas contemplando paisajes y momentos de reflexión. '
        'El video transmite serenidad y conexión con la naturaleza.';
  }
}