import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/services/database.dart';
import 'package:flutter/material.dart';

class OwnedCalendarFollowerTile extends StatelessWidget {
  final User user;
  final String calendarId;
  OwnedCalendarFollowerTile({this.user, this.calendarId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0), // padding outside the card
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
            vertical: 10.0, horizontal: 30.0), // padding inside the card
        title: Row(
          children: [
            Text(user.displayName),
            FlatButton(
                onPressed: () {
                  DatabaseService(userId: user.userId, calendarId: calendarId)
                      .leaveCalendar();
                },
                child: Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }
}
