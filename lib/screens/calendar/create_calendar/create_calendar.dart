import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/services/auth.dart';
import 'package:blok_p1/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateCalendar extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('\"Create calendar\"', style: TextStyle(fontSize: 20)),
        ),
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 115.0),
            child: Column(
              children: [
                ElevatedButton(
                  child: Text('Generate a dummy calendar'),
                  onPressed: () async {
                    await DatabaseService(userId: user.userId)
                        .createCalendar("dummy name");
                  },
                ),
              ],
            )));
  }
}
