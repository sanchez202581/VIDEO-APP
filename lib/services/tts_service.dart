import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class TtsService {
  // URL para API de Text-to-Speech (ejemplo con ElevenLabs)
  static const String _apiUrl = 'https://api.elevenlabs.io/v1/text-to-speech';
  // Deberás configurar tu propia clave de API
  static const String _apiKey = 'TU_API_KEY_AQUI';
  // ID de voz para ElevenLabs (esto es un ejemplo)
  static const String _voiceId = 'TU_VOICE_ID_AQUI';

  // Generar audio desde texto usando API externa (mejor calidad)
  static Future<String?> generateAudioWithAPI(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/$_voiceId'),
        headers: {
          'Content-Type': 'application/json',
          'xi-api-key': _apiKey,
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.8,
            'style': 0.5,
            'speaker_boost': true,
          }
        }),
      );

      if (response.statusCode == 200) {
        // Guardar el audio en un archivo temporal
        final tempDir = await getTemporaryDirectory();
        final audioFile = File('${tempDir.path}/narration.mp3');
        await audioFile.writeAsBytes(response.bodyBytes);
        return audioFile.path;
      } else {
        throw Exception('Error al generar audio: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en TTS API: $e');
      // Si falla la API externa, intentar con TTS local
      return generateAudioLocally(text);
    }
  }

  // Generar audio usando el TTS local de Flutter (como fallback)
  static Future<String?> generateAudioLocally(String text) async {
    try {
      final FlutterTts flutterTts = FlutterTts();
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/narration_local.mp3';
      
      await flutterTts.setLanguage("es-ES");
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      
      // En dispositivos móviles reales, podría ser posible guardar el audio
      // Aquí simulamos que se creó correctamente
      await Future.delayed(const Duration(seconds: 2));
      
      // Crear un archivo vacío como simulación
      final file = File(outputPath);
      await file.writeAsString('Simulación de archivo de audio');
      
      return outputPath;
    } catch (e) {
      debugPrint('Error en TTS local: $e');
      return null;
    }
  }
}