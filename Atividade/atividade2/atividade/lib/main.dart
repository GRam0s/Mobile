import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
    ),
    home: ListaCompras(),
  ));
}

class ListaCompras extends StatefulWidget {
  @override
  _ListaComprasState createState() => _ListaComprasState();
}

class _ListaComprasState extends State<ListaCompras> {
  List<String> itens = [];
  List<bool> comprado = [];
  TextEditingController controller = TextEditingController();

  // ✅ PASSO 1 – Adicionar item
  void adicionarItem() {
    if (controller.text.isNotEmpty) {
      setState(() {
        itens.add(controller.text); // ← adiciona o texto
        comprado.add(false);        // ← começa como NÃO comprado
        controller.clear();
      });
      salvarDados();
    }
  }

  // ✅ PASSO 2 – Alternar comprado/não comprado
  void alternarComprado(int index) {
    setState(() {
      comprado[index] = !comprado[index]; // ← inverte o estado (true→false / false→true)
    });
    salvarDados();
  }

  // ✅ Remover item
  void removerItem(int index) {
    setState(() {
      itens.removeAt(index);
      comprado.removeAt(index);
    });
    salvarDados();
  }

  // ✅ 🔥 DESAFIO EXTRA – Limpar lista inteira
  void limparLista() {
    setState(() {
      itens.clear();
      comprado.clear();
    });
    salvarDados();
  }

  // ✅ PASSO 3 – Salvar dados
  void salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("itens", itens);
    prefs.setStringList(
      "comprado",
      comprado.map((e) => e.toString()).toList(), // ← converte bool para String
    );
  }

  // ✅ PASSO 4 – Carregar dados
  void carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      itens = prefs.getStringList("itens") ?? [];
      List<String> listaBool = prefs.getStringList("comprado") ?? [];
      comprado = listaBool.map((e) => e == "true").toList(); // ← converte String para bool
    });
  }

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  // ✅ 🔥 DESAFIO EXTRA – Contador de itens
  int get totalItens => itens.length;
  int get itensMarcados => comprado.where((c) => c).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Compras"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 🔥 Botão "Limpar lista"
          if (itens.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              tooltip: "Limpar lista",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text("Limpar tudo?"),
                    content: Text("Tem certeza que quer remover todos os itens?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () {
                          limparLista();
                          Navigator.pop(ctx);
                        },
                        child: Text("Limpar", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // 🔥 Contador de itens
          if (itens.isNotEmpty)
            Container(
              color: Colors.teal.shade50,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total: $totalItens item${totalItens != 1 ? 's' : ''}"),
                  Text(
                    "✅ $itensMarcados comprado${itensMarcados != 1 ? 's' : ''}",
                    style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // Campo de texto
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Adicionar item",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => adicionarItem(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: adicionarItem,
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Lista de itens
          Expanded(
            child: itens.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text("Lista vazia!", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: itens.length,
                    itemBuilder: (context, index) {
                      final estaComprado = comprado[index];

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        // 🔥 Cor diferente quando comprado
                        color: estaComprado ? Colors.green.shade50 : null,
                        child: ListTile(
                          leading: Checkbox(
                            value: estaComprado,
                            onChanged: (_) => alternarComprado(index),
                            activeColor: Colors.teal,
                          ),
                          title: Text(
                            itens[index],
                            style: TextStyle(
                              // ✅ DESAFIO VISUAL – Texto riscado se comprado
                              decoration: estaComprado
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: estaComprado ? Colors.grey : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade300),
                            onPressed: () => removerItem(index),
                          ),
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