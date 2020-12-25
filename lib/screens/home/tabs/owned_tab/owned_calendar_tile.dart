import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/owned_calendar.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/owned_calendar_arguments.dart';
import 'package:flutter/material.dart';

class OwnedCalendarTile extends StatelessWidget {
  final Calendar calendarDetails;
  OwnedCalendarTile({this.calendarDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(
            20.0, 6.0, 20.0, 0.0), // padding outside the card
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
              vertical: 60.0, horizontal: 30.0), // padding inside the card
          leading: null,
          title: Text(calendarDetails.name),
          //subtitle: Text(calendar.description),
          onTap: () {
            Navigator.pushNamed(context, OwnedCalendar.route,
                arguments: OwnedCalendarArguments(
                    calendarId: calendarDetails.calendarId));
          },
        ),
      ),
    );
  }
}
