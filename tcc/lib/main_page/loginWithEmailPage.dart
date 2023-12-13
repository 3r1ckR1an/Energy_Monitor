import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/main.dart';
import 'createUserWithEmailAndPassword.dart';
import 'sendPasswordResetEmail.dart';

class LoginWithEmailPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void _login(BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Navigate to the tcc() page after a successful login.
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Tcc()));
    } catch (e) {
      String errorMessage = '';
      switch (e.toString()) {
        case '[firebase_auth/invalid-email] The email address is badly formatted.':
          errorMessage = 'Falha no login: endereço de e-mail mal formatado.';
          break;
        case '[firebase_auth/channel-error] Unable to establish connection on channel.':
          errorMessage = 'Falha no login: insira o e-mail e senha.';
          break;
        case '[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.':
          errorMessage = 'Falha no login: nenhum usuário encontrado com esse e-mail e senha.';
          break;
        case '[firebase_auth/wrong-password] The password is invalid or the user does not have a password.':
          errorMessage = 'Falha no login: senha inválida.';
          break;
      // Add more cases for other error messages if needed
        default:
          errorMessage = e.toString();
      }
      // Handle login error, e.g., display an error message.
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
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        color: Colors.grey[900], // Set the background color here
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/logo_oficial.png',
                    width: 300, // Set a maximum width for the image
                    height: 200,  // Set a maximum height for the image
                  ),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white), // Set the input text color to white
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: TextStyle(color: Colors.blue), // Set the label color to white
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Set the underline color to white
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to the registration screen.
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                      },
                      child: Text(
                        'Criar conta',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow[300]),
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
                      // Set the input text color to white
                      hintStyle: TextStyle(color: Colors.white), // This is where you set the text color
                    ),
                    obscureText: true,
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to the password reset screen.
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));
                      },
                      child: Text(
                        'Esqueci minha senha',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow[300]),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _login(context);
                    },
                    child: Text('ENTRAR'),
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
