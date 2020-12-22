import 'package:blok_p1/screens/authenticate/register/register.dart';
import 'package:blok_p1/screens/authenticate/sign_in/sign_in.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  bool register = true;

  Authenticate({this.register});

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.register ? Register() : SignIn(),
    );
  }
}
