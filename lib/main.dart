import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/screens/authenticate/convert/convert.dart';
import 'package:blok_p1/screens/calendar/create_calendar/create_calendar.dart';
import 'package:blok_p1/screens/calendar/join_calendar/join_calendar.dart';
import 'package:blok_p1/screens/home/home.dart';
import 'package:blok_p1/screens/wrapper.dart';
import 'package:blok_p1/services/auth.dart';
import 'package:blok_p1/screens/authenticate/authenticate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final routes = {
    '/': (context) => Wrapper(),
    '/calendar': (context) => Wrapper(),
    '/authenticate/register': (context) => Authenticate(
          register: true,
        ),
    '/authenticate/sign-in': (context) => Authenticate(
          register: false,
        ),
    '/authenticate/convert': (context) => Convert(),
    '/calendar/create': (context) => CreateCalendar(),
    '/calendar/join': (context) => JoinCalendar(),
    '/calendar/:id': (context) => Home(),
    '/calendar/:id/details': (context) => Home(),
  };

  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        routes: routes,
      ),
    );
  }
}
