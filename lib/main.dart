import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isConnected = false;

  Future<void> testInternetConnection() async {
    try {
      final response = await http.get(Uri.parse("https://www.google.com"));
      if (response.statusCode == 200) {
        setState(() {
          isConnected = true;
        });
      }
    } catch (e) {
      setState(() {
        isConnected = false;
      });
    }
  }

  void toggleConnection() async {
    if (isConnected) {
      setState(() {
        isConnected = false;
      });
    } else {
      await testInternetConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Internet Gratis - Proxy VPS")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isConnected ? "Conectado ✅" : "Desconectado ❌",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleConnection,
              child: Text(isConnected ? "Desconectar" : "Conectar"),
            ),
          ],
        ),
      ),
    );
  }
}
