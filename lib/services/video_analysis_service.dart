import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:flutter/foundation.dart';

class VideoAnalysisService {
  // Extraer fotogramas clave del video para análisis
  static Future<List<String>> extractKeyFrames(File videoFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/frames';

      // Crear directorio si no existe
      final directory = Directory(outputPath);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      // Extraer un fotograma cada 5 segundos
      final command =
          '-i "${videoFile.path}" -vf fps=1/5 "$outputPath/frame-%03d.jpg"';

      await FFmpegKit.executeAsync(command);

      // Listar los archivos de fotogramas extraídos
      final framesDir = Directory(outputPath);
      final List<FileSystemEntity> files = framesDir.listSync();

      return files
          .where((file) => file.path.endsWith('.jpg'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      debugPrint('Error en extracción de fotogramas: $e');
      return [];
    }
  }

  // Extraer clips de video basados en momentos importantes
  static Future<List<String>> extractImportantClips(
      File videoFile, List<Map<String, dynamic>> keyMoments) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final clipsDir = '${tempDir.path}/clips';

      // Crear directorio si no existe
      final directory = Directory(clipsDir);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      List<String> clipPaths = [];

      // Extraer cada clip importante basado en los momentos clave
      for (int i = 0; i < keyMoments.length; i++) {
        final moment = keyMoments[i];
        final startTime = moment['startTime']; // en segundos
        final duration = moment['duration']; // en segundos

        final outputPath = '$clipsDir/clip_$i.mp4';

        final command =
            '-ss $startTime -i "${videoFile.path}" -t $duration -c copy "$outputPath"';

        await FFmpegKit.executeAsync(command);
        clipPaths.add(outputPath);
      }

      return clipPaths;
    } catch (e) {
      debugPrint('Error en extracción de clips: $e');
      return [];
    }
  }

  // Combinar clips en un solo video
  static Future<String?> combineClips(
      List<String> clipPaths, String narrationAudioPath) async {
    try {
      if (clipPaths.isEmpty) return null;

      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/combined_video.mp4';
      final listFilePath = '${tempDir.path}/clips_list.txt';

      // Crear archivo de lista para FFmpeg
      final listFile = File(listFilePath);
      String fileContent = '';
      for (String clipPath in clipPaths) {
        fileContent += "file '$clipPath'\n";
      }
      await listFile.writeAsString(fileContent);

      // Combinar clips
      final combineCommand =
          '-f concat -safe 0 -i "$listFilePath" -c copy "${tempDir.path}/temp_combined.mp4"';

      await FFmpegKit.executeAsync(combineCommand);

      // Agregar narración de audio al video combinado
      final audioCommand =
          '-i "${tempDir.path}/temp_combined.mp4" -i "$narrationAudioPath" '
          '-map 0:v -map 1:a -c:v copy -shortest "$outputPath"';

      await FFmpegKit.executeAsync(audioCommand);

      return outputPath;
    } catch (e) {
      debugPrint('Error al combinar clips: $e');
      return null;
    }
  }
}
