import 'package:blok_p1/services/auth.dart';
import 'package:flutter/material.dart';

class QuickStart extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 120.0),
        child: Form(
          child: Column(
            children: [
              Text('Blok', style: TextStyle(fontSize: 50)),
              SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/authenticate/register');
                  },
                  child: Text('Start Organizing')),
              SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                  onPressed: () async {
                    dynamic result = await _auth.signInAnon();
                    if (result == null) {
                      print('Error signing in as anon');
                    } else {
                      Navigator.pushNamed(context, '/calendar/join');
                    }
                  },
                  child: Text('Join event')),
              SizedBox(
                height: 20.0,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/authenticate/sign-in',
                    );
                  },
                  child: Text('Have an account?')),
            ],
          ),
        ),
      ),
    );
  }
}
