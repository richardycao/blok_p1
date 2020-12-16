import 'package:blok_p1/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        elevation: 0.0,
        title: Text('Sign in with email'),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Text('sign in (placeholder)')
          // child: RaisedButton(
          //   child: Text('Sign in with credentials'),
          //   onPressed: () async {
          //     dynamic result = await _auth.signInAnon();
          //     if (result == null) {
          //       print('Error signing in.');
          //     } else {
          //       print('Signed in');
          //       print(result.userId);
          //       Navigator.pop(context);
          //     }
          //   },
          // ),
          ),
    );
  }
}
