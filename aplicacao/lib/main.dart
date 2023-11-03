import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Aplicacao()
  ));
}


class Aplicacao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold( //Barra de cima
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Monitoramento de Energia'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: Padding( //conteudo
        padding: EdgeInsets.fromLTRB(30, 40, 30, 0), //posicao na tela
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/kanna.jpg'),
                radius: 40,
              ),
            ),
            Divider(
              height: 50,
              color: Colors.grey[800],
            ),
            const Text(
              'Nome',
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Erick Rian',
              style: TextStyle(
                color: Colors.amberAccent[200],
                letterSpacing: 2,
                fontSize: 28,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Nivel Atual',
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '8',
              style: TextStyle(
                  color: Colors.amberAccent[200],
                  letterSpacing: 2,
                  fontSize: 28,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: <Widget>[
                Icon(
                  Icons.email,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 10),
                Text(
                  'erickrian@gmail.com',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
