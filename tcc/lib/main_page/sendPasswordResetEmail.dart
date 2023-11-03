import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loginWithEmailPage.dart';

class ResetPasswordPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController emailController = TextEditingController();

  void _resetPassword(BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text);
      // Password reset email sent successfully, show a success message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('E-mail de redefinição de senha enviado para ${emailController.text}.'),
        ),
      );
      // Customize the behavior of the arrow button here
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginWithEmailPage()));
    } catch (e) {
      String errorMessage = '';
      switch (e.toString()) {
        case '[firebase_auth/channel-error] Unable to establish connection on channel.':
          errorMessage = 'Falha na recuperação da senha: insira o e-mail.';
          break;
        case '[firebase_auth/invalid-email] The email address is badly formatted.':
          errorMessage = 'Falha na recuperação da senha: endereço de          e-mail mal formatado.';
          break;
      // Add more cases for other error messages if needed
        default:
          errorMessage = e.toString();
      }

      // Handle password reset error, e.g., display an error message.
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
        title: Text('Esqueci minha senha'),
        centerTitle: true,
        backgroundColor: Colors.grey[850], // Set the background color of the app bar
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Customize the icon here
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginWithEmailPage()));
          },
        ),
      ),
      resizeToAvoidBottomInset: true, // Allow content to move when the keyboard is displayed
      body: Container(
        color: Colors.grey[900], // Set the background color here
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            margin: EdgeInsets.only(top: 150),
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/logo.png',
                    width: 300, // Set a maximum width for the image
                    height: 200,  // Set a maximum height for the image
                  ),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: TextStyle(color: Colors.blue), // Set the label color to white
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Set the underline color to white
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _resetPassword(context);
                    },
                    child: Text('CONFIRMAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor, // Set the primary color to match 'ENTRAR' button
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
