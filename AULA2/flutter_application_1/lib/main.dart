import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Color.fromARGB(255, 0, 255, 0),
        appBar: AppBar(
          title: const Text('Hello World App'),
          backgroundColor: Color.fromARGB(255, 255, 0, 0),
        ),
        body: const Center(
          child: Text('Olá Mundo'),
        ),
      ),
    );
  }
}
