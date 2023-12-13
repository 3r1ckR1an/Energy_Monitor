import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '/main.dart'; // Import the file where Tcc class is defined
import 'package:tcc/main_page/loginWithEmailPage.dart';

class LoginPage extends StatelessWidget {
  void _onLoginButtonPressed(BuildContext context) {
    // Navigate to the Tcc class when the Login button is pressed
    Navigator.push(context, MaterialPageRoute(builder: (context) => Tcc()));
  }

  Future<void> _handleSignInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      print('Google sign-in canceled or failed.');
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser
        .authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final UserCredential authResult = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        print('Google sign-in successful. User email: ${user.email}');
        _onLoginButtonPressed(context); // Navigate to Tcc class or other logic
      } else {
        print('Firebase user is null after successful sign-in.');
      }
    } catch (e) {
      print('Firebase sign-in error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 150), // Add margin to move the logo down
                child: Image.asset(
                  'assets/logo_oficial.png',
                  width: 300,
                  height: 300,
                ),
              ),
              Container(
                width: 200,
                child: Column(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        _handleSignInWithGoogle(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Image.asset(
                                'assets/gmail.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Entrar com Google',
                            style: TextStyle(
                              color: Colors.grey[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    const Row(
                      children: <Widget>[
                        Expanded(
                          child: Divider(
                            color: Colors.white,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'OU',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (
                            context) => LoginWithEmailPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: Size(200, 40),
                      ),
                      child: Text(
                        'Entrar com E-mail',
                        softWrap: true,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

  void main() {
  runApp(
    MaterialApp(
      home: LoginPage(),
    ),
  );
}
