import 'dart:math';

import 'package:blok_p1/screens/common/loading.dart';
import 'package:blok_p1/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateCalendar extends StatelessWidget {
  static const route = '/calendar/create';

  @override
  Widget build(BuildContext context) {
    final FirebaseUser user = Provider.of<FirebaseUser>(context);
    if (user == null) {
      return Loading();
    }

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
                    await DatabaseService(userId: user.uid).createCalendar(
                        "name " + Random.secure().nextInt(10000).toString());
                  },
                ),
              ],
            )));
  }
}
