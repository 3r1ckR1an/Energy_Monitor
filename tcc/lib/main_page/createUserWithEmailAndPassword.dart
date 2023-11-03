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
      String errorMessage = '';
      switch (e.toString()) {
        case '[firebase_auth/invalid-email] The email address is badly formatted.':
          errorMessage = 'Falha no cadastro: endereço de e-mail mal formatado.';
          break;
        case '[firebase_auth/channel-error] Unable to establish connection on channel.':
          errorMessage = 'Falha no cadastro: insira o e-mail e senha.';
          break;
        case '[firebase_auth/weak-password] Password should be at least 6 characters':
          errorMessage = 'Falha no cadastro: senha deve ter no mínimo 6 caracteres.';
          break;
      // Add more cases for other error messages if needed
        default:
          errorMessage = e.toString();
      }
      // Handle registration error, e.g., display an error message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow content to move when the keyboard is displayed
      appBar: AppBar(
        title: const Text('Criar Conta'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
            margin: const EdgeInsets.only(top: 110),
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/logo.png',
                    width: 300, // Set a maximum width for the image
                    height: 200,  // Set a maximum height for the image
                  ),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: TextStyle(color: Colors.blue),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      labelStyle: TextStyle(color: Colors.blue),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
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
