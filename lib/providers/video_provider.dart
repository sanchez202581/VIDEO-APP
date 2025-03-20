import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_app/services/api_service.dart';
import 'package:video_app/services/tts_service.dart';
import 'package:video_app/services/video_analysis_service.dart';

enum ProcessingStatus {
  idle,
  loading,
  analyzing,
  generating,
  editing,
  completed,
  error
}

class VideoProvider extends ChangeNotifier {
  File? _videoFile;
  String? _generatedNarration;
  File? _processedVideo;
  String? _narrationAudioPath;
  ProcessingStatus _status = ProcessingStatus.idle;
  String _statusMessage = '';
  double _progress = 0.0;
  
  // Getters
  File? get videoFile => _videoFile;
  String? get generatedNarration => _generatedNarration;
  File? get processedVideo => _processedVideo;
  ProcessingStatus get status => _status;
  String get statusMessage => _statusMessage;
  double get progress => _progress;
  
  // Setters que notifican cambios
  void setVideoFile(File file) {
    _videoFile = file;
    _processedVideo = null;
    _generatedNarration = null;
    _status = ProcessingStatus.idle;
    _progress = 0.0;
    notifyListeners();
  }
  
  void _updateStatus(ProcessingStatus status, String message, {double progress = 0.0}) {
    _status = status;
    _statusMessage = message;
    _progress = progress;
    notifyListeners();
  }
  
  // Proceso completo de análisis y edición
  Future<bool> processVideo() async {
    if (_videoFile == null) {
      _updateStatus(ProcessingStatus.error, 'No hay video seleccionado');
      return false;
    }
    
    try {
      // 1. Analizar el video
      _updateStatus(ProcessingStatus.analyzing, 'Analizando el video...', progress: 0.1);
      final videoDescription = await _analyzeVideo();
      if (videoDescription == null) return false;
      
      // 2. Generar narración
      _updateStatus(ProcessingStatus.generating, 'Generando narración reflexiva...', progress: 0.3);
      bool narrated = await _generateNarration(videoDescription);
      if (!narrated) return false;
      
      // 3. Convertir texto a voz
      _updateStatus(ProcessingStatus.generating, 'Creando audio de narración...', progress: 0.5);
      bool audioGenerated = await _generateAudio();
      if (!audioGenerated) return false;
      
      // 4. Editar el video
      _updateStatus(ProcessingStatus.editing, 'Editando escenas clave...', progress: 0.7);
      bool edited = await _editVideo();
      if (!edited) return false;
      
      _updateStatus(ProcessingStatus.completed, 'Video procesado con éxito', progress: 1.0);
      return true;
    } catch (e) {
      _updateStatus(ProcessingStatus.error, 'Error: ${e.toString()}');
      return false;
    }
  }
  
  // Análisis del video con extracción de fotogramas clave
  Future<String?> _analyzeVideo() async {
    try {
      // Extraer fotogramas para análisis
      final keyFrames = await VideoAnalysisService.extractKeyFrames(_videoFile!);
      
      // En una aplicación real, enviarías estos fotogramas a una API de visión
      // como Google Cloud Vision o Azure Computer Vision
      
      // Por ahora, simulamos el análisis
      final videoDescription = await ApiService.analyzeVideoContent(_videoFile!.path);
      
      return videoDescription;
    } catch (e) {
      _updateStatus(ProcessingStatus.error, 'Error al analizar el video: ${e.toString()}');
      return null;
    }
  }
  
  // Generación de narración con IA
  Future<bool> _generateNarration(String videoDescription) async {
    try {
      // Generar narración con GPT-4 Turbo
      _generatedNarration = await ApiService.generateNarration(videoDescription);
      
      notifyListeners();
      return true;
    } catch (e) {
      _updateStatus(ProcessingStatus.error, 'Error al generar la narración: ${e.toString()}');
      return false;
    }
  }
  
  // Generación de audio a partir del texto
  Future<bool> _generateAudio() async {
    if (_generatedNarration == null) return false;
    
    try {
      // Generar audio usando servicio TTS externo
      _narrationAudioPath = await TtsService.generateAudioWithAPI(_generatedNarration!);
      
      if (_narrationAudioPath == null) {
        throw Exception('No se pudo generar el audio');
      }
      
      return true;
    } catch (e) {
      _updateStatus(ProcessingStatus.error, 'Error al generar el audio: ${e.toString()}');
      return false;
    }
  }
  
  // Edición del video
  Future<bool> _editVideo() async {
    try {
      if (_narrationAudioPath == null) {
        throw Exception('No se ha generado el audio de narración');
      }
      
      // Definir momentos clave (en una app real, esto se determinaría mediante análisis de IA)
      final keyMoments = [
        {'startTime': 0, 'duration': 5},
        {'startTime': 10, 'duration': 7},
        {'startTime': 20, 'duration': 6},
        {'startTime': 30, 'duration': 8},
      ];
      
      // Extraer clips importantes
      final clips = await VideoAnalysisService.extractImportantClips(_videoFile!, keyMoments);
      
      if (clips.isEmpty) {
        throw Exception('No se pudieron extraer clips del video');
      }
      
      // Combinar clips con narración
      final outputPath = await VideoAnalysisService.combineClips(clips, _narrationAudioPath!);
      
      if (outputPath == null) {
        throw Exception('Error al combinar los clips');
      }
      
      // Copiar al directorio de documentos para acceso permanente
      final appDocDir = await getApplicationDocumentsDirectory();
      final finalPath = '${appDocDir.path}/processed_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      
      await File(outputPath).copy(finalPath);
      _processedVideo = File(finalPath);
      
      return true;
    } catch (e) {
      _updateStatus(ProcessingStatus.error, 'Error al editar el video: ${e.toString()}');
      return false;
    }
  }
  
  // Limpiar recursos
  void reset() {
    _videoFile = null;
    _generatedNarration = null;
    _processedVideo = null;
    _narrationAudioPath = null;
    _status = ProcessingStatus.idle;
    _statusMessage = '';
    _progress = 0.0;
    notifyListeners();
  }
}