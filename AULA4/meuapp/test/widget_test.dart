import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<String> tarefas = [];
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
      ),
      body: Column(
        children: [
          TextField(
            controller: controller,
          ),
          ElevatedButton(
            onPressed: adicionarTarefa,
            child: const Text('Adicionar'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tarefas[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => removerTarefa(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void adicionarTarefa() {
    setState(() {
      tarefas.add(controller.text);
    });
    controller.clear();
  }

  void removerTarefa(int index) {
    setState(() {
      tarefas.removeAt(index);
    });
  }
}