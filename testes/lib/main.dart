import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logo.png', width: 150, height: 150), // Replace 'assets/logo.png' with your logo image path
            SizedBox(height: 20),
            Text(
              'Login',
              style: TextStyle(fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true, // To hide the password
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Add your login logic here
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
