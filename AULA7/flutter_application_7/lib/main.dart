import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: TelaInicio()));
}

class TelaInicio extends StatefulWidget {
  @override
  State<TelaInicio> createState() => _TelaInicioState();
}

class _TelaInicioState extends State<TelaInicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tela inicial"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("Ir para a segunda tela"),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SegundaTela()));
          },
        ),
      ),
    );
  }
}

//------SEGUNDA_TELA-------

class SegundaTela extends StatefulWidget {
  final String nome = "Gabriel Ramos";

  @override
  State<SegundaTela> createState() => _SegundaTelaState();
}

class _SegundaTelaState extends State<SegundaTela> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bem-vindo à Segunda tela, ${widget.nome}!"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("Voltar para a tela inicial"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}