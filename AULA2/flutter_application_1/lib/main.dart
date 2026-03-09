import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, 
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const PaginaContador(),
    );
  }
}

class PaginaContador extends StatefulWidget {
  const PaginaContador({super.key});

  @override
  State<PaginaContador> createState() => _PaginaContadorState();
}

class _PaginaContadorState extends State<PaginaContador> {
  int numero = 0;

  void aumentar() {
    setState(() {
      numero++;
    });
  }

  void diminuir() {
    setState(() {
      if (numero > 0) numero--;
    });
  }

  void zerar() {
    setState(() {
      numero = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teste Contador"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Contagem Atual", style: TextStyle(fontSize: 18)),
            Text(
              "$numero",
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: diminuir,
            backgroundColor: Colors.red,
            child: const Icon(Icons.remove, color: Colors.white),
          ),

          const SizedBox(width: 15),

          FloatingActionButton(
            onPressed: aumentar,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
          ),

const SizedBox(width: 15),
          FloatingActionButton(
            onPressed: zerar,
            backgroundColor: const Color.fromARGB(255, 107, 107, 107),
            child: const Text("Zerar" , style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}