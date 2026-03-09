// import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TodoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<String> Tarefas = [];
  final TextEditingController controller = TextEditingController();

  void adicionarTarefa(String text) {
    setState(() {
      if (controller.text.isEmpty) return;
      Tarefas.add(controller.text);
    });
    controller.clear();
  }

  void removerTarefa(int index) {
    setState(() {
      Tarefas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de Tarefas ${Tarefas.length}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          TextField(
            controller: controller,
            onSubmitted: (valor) {
              adicionarTarefa(valor);
            },
          ),
          ElevatedButton(
            onPressed: () {
              adicionarTarefa(controller.text);
            },
            child: const Text("Adicionar"),
          ),
          Expanded(
            child: Tarefas.isEmpty
                ? Center(
                    child: Text("Nehuma Tarefa Adicionada!", style: TextStyle(fontSize: 18, color: Colors.grey),),
                  )
                : ListView.builder(
                    itemCount: Tarefas.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(Tarefas[index]),
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
}