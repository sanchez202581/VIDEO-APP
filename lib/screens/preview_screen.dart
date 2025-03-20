import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_app/providers/video_provider.dart';
import 'package:video_app/screens/result_screen.dart';
import 'package:video_app/widgets/video_player_widget.dart';
import 'package:video_app/widgets/processing_indicator.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isProcessing = false;

  Future<void> _processVideo() async {
    setState(() {
      _isProcessing = true;
    });

    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    final success = await videoProvider.processVideo();

    setState(() {
      _isProcessing = false;
    });

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ResultScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);
    final videoFile = videoProvider.videoFile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Previa'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (videoFile != null) ...[
                VideoPlayerWidget(videoFile: videoFile),
                const SizedBox(height: 20),
                Text(
                  'Video seleccionado: ${videoFile.path.split('/').last}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                if (_isProcessing) ...[
                  const ProcessingIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    videoProvider.statusMessage,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: videoProvider.progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ] else ...[
                  const Text(
                    'La IA analizará tu video para crear una narración reflexiva inspirada en el estilo de Farid Dieck y editará automáticamente las escenas clave.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _processVideo,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Procesar con IA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ],
              ] else ...[
                const Center(
                  child: Text('No se ha seleccionado ningún video'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}