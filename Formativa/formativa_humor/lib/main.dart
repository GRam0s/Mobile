import 'package:flutter/material.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Humor App',
      home: const TelaHumor(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TelaHumor extends StatefulWidget {
  const TelaHumor({super.key});

  @override
  State<TelaHumor> createState() => _TelaHumorState();
}

class _TelaHumorState extends State<TelaHumor> {
  int humorIndex = 0;

  final List<String> humores = [
    "😀 Feliz",
    "😐 Neutro",
    "😡 Bravo",
  ];

  void mudarHumor() {
    setState(() {
      humorIndex = (humorIndex + 1) % humores.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Controle de Humor"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              humores[humorIndex],
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: mudarHumor,
              child: const Text("Mudar Humor"),
            ),
          ],
        ),
      ),
    );
  }
}