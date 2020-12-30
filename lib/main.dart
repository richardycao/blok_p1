import 'package:blok_p1/screens/authenticate/convert/convert.dart';
import 'package:blok_p1/screens/authenticate/register/register.dart';
import 'package:blok_p1/screens/authenticate/sign_in/sign_in.dart';
import 'package:blok_p1/screens/calendar/create_calendar/create_calendar.dart';
import 'package:blok_p1/screens/calendar/followed_calendar/followed_calendar.dart';
import 'package:blok_p1/screens/calendar/join_calendar/join_calendar.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/owned_calendar.dart';
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
    Wrapper.route: (context) => Wrapper(),
    Authenticate.route: (context) => Authenticate(
          register: false,
        ),
    Register.route: (context) => Authenticate(
          register: true,
        ),
    SignIn.route: (context) => Authenticate(
          register: false,
        ),
    Convert.route: (context) => Convert(),
    '/calendar': (context) => Wrapper(),
    CreateCalendar.route: (context) => CreateCalendar(),
    JoinCalendar.route: (context) => JoinCalendar(),
    OwnedCalendarPage.route: (context) => OwnedCalendarPage(),
    FollowedCalendarPage.route: (context) => FollowedCalendarPage(),
    '/calendar/:id/details': (context) => Home(),
  };

  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        initialRoute: '/',
        routes: routes,
      ),
    );
  }
}
