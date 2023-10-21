import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/main.dart';
import 'loginWithEmailPage.dart';

class RegisterPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void _createAccount(BuildContext context) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Registration successful, navigate to the Tcc page or any other desired page.
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Tcc()));
    } catch (e) {
      // Handle registration error, e.g., display an error message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Falha no Cadastro: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow content to move when the keyboard is displayed
      appBar: AppBar(
        title: Text('Criar Conta'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginWithEmailPage()));
          },
        ),
      ),
      body: Container(
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Image.asset('assets/logo.png'),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.blue),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: TextStyle(color: Colors.blue),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _createAccount(context);
                    },
                    child: Text('CONFIRMAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
