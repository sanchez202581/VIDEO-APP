import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_app/providers/video_provider.dart';
import 'package:video_app/screens/preview_screen.dart';
import 'package:video_app/screens/result_screen.dart';
import 'package:video_app/widgets/processing_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      context.read<VideoProvider>().setVideoFile(file);
      
      // Navegar a la pantalla de vista previa
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PreviewScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video App'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.video_library_rounded,
                size: 100,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              const Text(
                'Transformación de Videos con IA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Sube un video y deja que nuestra IA lo analice, cree una narración reflexiva y lo edite automáticamente.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.upload_file),
                label: const Text('Seleccionar Video'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              const SizedBox(height: 40),
              if (videoProvider.status == ProcessingStatus.loading ||
                  videoProvider.status == ProcessingStatus.analyzing ||
                  videoProvider.status == ProcessingStatus.generating ||
                  videoProvider.status == ProcessingStatus.editing)
                const ProcessingIndicator(),
              if (videoProvider.status == ProcessingStatus.error)
                Text(
                  videoProvider.statusMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}