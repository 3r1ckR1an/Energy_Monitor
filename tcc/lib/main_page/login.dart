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

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
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
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Set the mainAxisSize to min
            children: <Widget>[
              SizedBox(height: 10), // Add space for logo
              Image.asset('assets/logo.png', width: 550, height: 550), // Replace 'assets/logo.png' with your logo image path
              SizedBox(height: 10),
              Container(
                width: 200, // Adjust the width as needed
                child: Column(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        _handleSignInWithGoogle(context); // Handle Google sign-in
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Set the background color to red
                      ),
                      child: Row(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft, // Align the image to the left
                            child: Container(
                              padding: EdgeInsets.all(8), // Add padding to the inner container (adjust as needed)
                              child: Image.asset('assets/gmail.png', width: 24, height: 24),
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
                    SizedBox(height: 10),
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
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginWithEmailPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: Size(200, 40), // Adjust width and height as needed
                      ),
                      child: Text(
                        'Entrar com Email',
                        softWrap: true, // Allow text to wrap within the button
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Set the text to be bold (thicker)
                          color: Colors.grey[900], // Set the text color to grey[900]
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
