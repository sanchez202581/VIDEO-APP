import 'package:flutter/material.dart';
import 'package:flutter_vpn/flutter_vpn.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isConnected = false;
  String status = "Desconectado";

  @override
  void initState() {
    super.initState();
    FlutterVpn.onStateChanged.listen((dynamic stage) {
      setState(() {
        status = stage.toString();
        // Detectamos el estado conectado de manera más genérica
        isConnected = status.contains("connected") || status.contains("CONNECTED");
      });
    });
  }

  Future<void> startVPN() async {
    setState(() {
      status = "Conectando...";
    });

    await FlutterVpn.connectIkev2EAP(
      server: "facebook.com", // Cambia esto si usas otro servidor
      username: "",
      password: "",
    );
  }

  Future<void> stopVPN() async {
    await FlutterVpn.disconnect();
    setState(() {
      status = "Desconectado";
      isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Internet Gratis Claro")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Estado: $status", style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isConnected ? stopVPN : startVPN,
                child: Text(isConnected ? "Desconectar" : "Conectar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}