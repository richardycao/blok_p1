import 'package:blok_p1/constants/testing_constants.dart';
import 'package:blok_p1/screens/calendar/followed_calendar/followed_calendar.dart';
import 'package:blok_p1/screens/calendar/followed_calendar/followed_calendar_arguments.dart';
import 'package:blok_p1/screens/common/loading.dart';
import 'package:blok_p1/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinCalendar extends StatelessWidget {
  static const route = '/calendar/join';

  @override
  Widget build(BuildContext context) {
    final FirebaseUser firebaseUser = Provider.of<FirebaseUser>(context);
    if (firebaseUser == null) {
      return Loading();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('\"Join calendar\"', style: TextStyle(fontSize: 20)),
        ),
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 115.0),
            child: Column(
              children: [
                ElevatedButton(
                  child: Text('Scan QR code (does nothing)'),
                  onPressed: () async {},
                ),
                ElevatedButton(
                  child: Text('Join/request hard-coded calendar ID'),
                  onPressed: () async {
                    dynamic result = await DatabaseService()
                        .createJoinCalendarRequest(
                            firebaseUser.uid, testJoinCalendarId);
                    if (result) {
                      Navigator.popAndPushNamed(
                          context, FollowedCalendarPage.route,
                          arguments: FollowedCalendarArguments(
                              calendarId: testJoinCalendarId));
                    }
                  },
                ),
              ],
            )));
  }
}
