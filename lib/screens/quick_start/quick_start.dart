import 'package:blok_p1/screens/authenticate/register/register.dart';
import 'package:blok_p1/screens/authenticate/sign_in/sign_in.dart';
import 'package:blok_p1/services/auth.dart';
import 'package:blok_p1/styles/styles_quick_start.dart';
import 'package:flutter/material.dart';

class QuickStart extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 110.0),
        child: Form(
          child: Column(
            children: [
              Text('Blok', style: TextStyle(fontSize: 50)),
              SizedBox(
                height: 50.0,
              ),
              Text('I am an', style: TextStyle(fontSize: 20)),
              SizedBox(
                height: 10.0,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Register.route);
                  },
                  child: Text('Organizer', style: quickStartButtonFont)),
              SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                onPressed: () async {
                  dynamic result = await _auth.signInAnon();
                  if (result == null) {
                    print('Error signing in as anon');
                  }
                },
                child: Text('Attendee', style: quickStartButtonFont),
              ),
              SizedBox(
                height: 20.0,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      SignIn.route,
                    );
                  },
                  child: Text('Existing user?')),
            ],
          ),
        ),
      ),
    );
  }
}
