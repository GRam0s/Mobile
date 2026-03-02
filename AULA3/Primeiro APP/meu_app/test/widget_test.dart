import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: PaginaContador(),
    debugShowCheckedModeBanner: false,
  ));
}

class PaginaContador extends StatefulWidget {
  const PaginaContador({Key? key}) : super(key: key);

  @override
  State<PaginaContador> createState() => _PaginaContadorState();
}

class _PaginaContadorState extends State<PaginaContador> {
  int _contador = 0;

  void _incrementar() {
    setState(() {
      _contador++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contador'),
      ),
      body: Center(
        child: Text(
          'Valor: $_contador',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementar,
        child: const Icon(Icons.add),
      ),
    );
  }
}