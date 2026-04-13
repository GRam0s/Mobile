import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SalvarTextoApp(),
  ));
}

class SalvarTextoApp extends StatefulWidget {
  const SalvarTextoApp({super.key});

  @override
  State<SalvarTextoApp> createState() => _SalvarTextoAppState();
}

class _SalvarTextoAppState extends State<SalvarTextoApp> {
  final TextEditingController _textController = TextEditingController();
  String textoSalvo = '';

  @override
  void initState() {
    super.initState();
    carregarTexto(); // Carrega o texto salvo ao iniciar o app
  }

  @override
  void dispose() {
    _textController.dispose(); // Libera o controller da memória
    super.dispose();
  }

  Future<void> salvarTexto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('texto', _textController.text);

    setState(() {
      textoSalvo = _textController.text;
    });
  }

  Future<void> carregarTexto() async { // ✅ Corrigido para Future<void>
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      textoSalvo = prefs.getString('texto') ?? '';
      _textController.text = textoSalvo; // Preenche o campo com o texto salvo
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salvar Texto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Digite seu texto',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: salvarTexto,
              child: const Text('Salvar'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Texto salvo:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              textoSalvo.isEmpty ? 'Nenhum texto salvo.' : textoSalvo,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}