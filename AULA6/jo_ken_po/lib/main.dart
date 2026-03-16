import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: JogoApp(),
  ));
}

class JogoApp extends StatefulWidget {
  @override
  _JogoAppState createState() => _JogoAppState();
}

class _JogoAppState extends State<JogoApp> {

  IconData iconeComputador = Icons.help;
  String resultado = "Escolha uma opção";

  int pontosJogador = 0;
  int pontosComputador = 0;

  List opcoes = ["pedra","papel","tesoura"];

  void jogar(String escolhaUsuario){

    var numero = Random().nextInt(3);
    var escolhaComputador = opcoes[numero];

    setState(() {

      // Mostrar escolha do computador
      if(escolhaComputador == "pedra"){
        iconeComputador = Icons.landscape;
      }

      if(escolhaComputador == "papel"){
        iconeComputador = Icons.pan_tool;
      }

      if(escolhaComputador == "tesoura"){
        iconeComputador = Icons.content_cut;
      }

      // Lógica do jogo
      if(escolhaUsuario == escolhaComputador){
        resultado = "Empate";
      }

      else if(
      (escolhaUsuario == "pedra" && escolhaComputador == "tesoura") ||
      (escolhaUsuario == "papel" && escolhaComputador == "pedra") ||
      (escolhaUsuario == "tesoura" && escolhaComputador == "papel")
      ){
        pontosJogador++;

        if(pontosJogador == 5){
          resultado = "Você ganhou o campeonato!";
          pontosJogador = 0;
          pontosComputador = 0;
        }
        else{
          resultado = "Você venceu!";
        }
      }

      else{
        pontosComputador++;

        if(pontosComputador == 5){
          resultado = "Computador ganhou o campeonato!";
          pontosJogador = 0;
          pontosComputador = 0;
        }
        else{
          resultado = "Computador venceu!";
        }

      }

    });

  }

  void resetarPlacar(){
    setState(() {
      pontosJogador = 0;
      pontosComputador = 0;
      resultado = "Placar resetado!";
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Pedra Papel Tesoura"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text("Computador"),

            Icon(
              iconeComputador,
              size: 100,
            ),

            SizedBox(height: 20),

            Text(
              resultado,
              style: TextStyle(fontSize: 26),
            ),

            SizedBox(height: 10),

            Text(
              "Você: $pontosJogador | PC: $pontosComputador",
              style: TextStyle(fontSize: 20),
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                IconButton(
                  icon: Icon(Icons.landscape),
                  iconSize: 50,
                  onPressed: () => jogar("pedra"),
                ),

                IconButton(
                  icon: Icon(Icons.pan_tool),
                  iconSize: 50,
                  onPressed: () => jogar("papel"),
                ),

                IconButton(
                  icon: Icon(Icons.content_cut),
                  iconSize: 50,
                  onPressed: () => jogar("tesoura"),
                ),

              ],
            ),

            SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: resetarPlacar,
              icon: Icon(Icons.refresh),
              label: Text("Resetar Placar"),
            )

          ],
        ),
      ),
    );
  }
}