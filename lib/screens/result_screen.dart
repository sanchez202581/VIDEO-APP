import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_app/providers/video_provider.dart';
import 'package:video_app/widgets/video_player_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  Future<void> _shareVideo(BuildContext context) async {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    final processedVideo = videoProvider.processedVideo;
    
    if (processedVideo != null && processedVideo.existsSync()) {
      await Share.shareXFiles(
        [XFile(processedVideo.path)],
        text: 'Mira este video procesado con IA',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay video para compartir')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);
    final processedVideo = videoProvider.processedVideo;
    final narration = videoProvider.generatedNarration;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareVideo(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Video Procesado con IA',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (processedVideo != null && processedVideo.existsSync())
                VideoPlayerWidget(videoFile: processedVideo)
              else
                const Center(
                  child: Text('No se pudo procesar el video'),
                ),
              const SizedBox(height: 30),
              const Text(
                'Narración Generada:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  narration ?? 'No se generó narración',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _shareVideo(context),
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      videoProvider.reset();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Nuevo Video'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}