import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/screens/home/home.dart';
import 'package:blok_p1/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuickCreateCalendar extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);

    return Container(
        child: Column(
      children: [
        ElevatedButton(
          child: Text('Go to home page'),
          onPressed: () async {
            dynamic result = await _auth.signInAnon();
            if (result == null) {
              print('Error signing in as anon');
            }
            Navigator.pop(context);
          },
        ),
      ],
    ));
  }
}
