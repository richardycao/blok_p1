import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/screens/calendar/followed_calendar/followed_calendar.dart';
import 'package:blok_p1/screens/calendar/followed_calendar/followed_calendar_arguments.dart';
import 'package:flutter/material.dart';

class FollowedCalendarTile extends StatelessWidget {
  final Calendar calendarDetails;
  FollowedCalendarTile({this.calendarDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(
            20.0, 6.0, 20.0, 0.0), // padding outside the card
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
              vertical: 20.0, horizontal: 30.0), // padding inside the card
          leading: null,
          title: Text(calendarDetails.name),
          //subtitle: Text(calendar.description),
          onTap: () {
            Navigator.pushNamed(context, FollowedCalendarPage.route,
                arguments: FollowedCalendarArguments(
                    calendarId: calendarDetails.calendarId));
          },
        ),
      ),
    );
  }
}
