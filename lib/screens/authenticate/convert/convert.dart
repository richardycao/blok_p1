import 'package:blok_p1/screens/common/loading.dart';
import 'package:blok_p1/services/auth.dart';
import 'package:flutter/material.dart';

class Convert extends StatefulWidget {
  static const route = '/authenticate/convert';

  final Function toggleView;
  Convert({this.toggleView});

  @override
  _ConvertState createState() => _ConvertState();
}

class _ConvertState extends State<Convert> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  // text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Text('Convert with email'),
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Email',
                      ),
                      validator: (val) =>
                          val.isEmpty ? "Email cannot be empty" : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Password',
                      ),
                      obscureText: true,
                      validator: (val) => val.length < 8
                          ? "Enter a password with 8 or more characters"
                          : null,
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                      color: Colors.blue[900],
                      child: Text('Convert',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() => loading = true);
                          dynamic result = await _auth
                              .convertUserWithEmailAndPassword(email, password);
                          if (result == null) {
                            setState(() {
                              error = 'Error with those credentials';
                              loading = false;
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
