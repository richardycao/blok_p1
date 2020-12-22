import 'package:blok_p1/screens/authenticate/sign_in/sign_in.dart';
import 'package:blok_p1/screens/calendar/create_calendar/create_calendar.dart';
import 'package:flutter/material.dart';

class QuickStart extends StatelessWidget {
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
                  child: Text('Create calendar')),
              SizedBox(
                height: 20.0,
              ),
              // ElevatedButton(onPressed: null, child: Text('Join calendar')),
              // SizedBox(
              //   height: 20.0,
              // ),
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
