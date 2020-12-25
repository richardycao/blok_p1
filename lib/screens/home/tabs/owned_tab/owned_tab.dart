import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/screens/common/loading.dart';
import 'package:blok_p1/screens/home/tabs/owned_tab/owned_calendar_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OwnedCalendars extends StatefulWidget {
  @override
  _OwnedCalendarsState createState() => _OwnedCalendarsState();
}

class _OwnedCalendarsState extends State<OwnedCalendars> {
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    if (user == null) {
      return Loading(
        blank: true,
      );
    }

    final List<Calendar> ownedCalendars =
        user.ownedCalendars.entries.map((entry) {
      return Calendar(calendarId: entry.key, name: entry.value);
    }).toList();

    return ListView.builder(
      itemCount: ownedCalendars.length,
      itemBuilder: (context, index) {
        return OwnedCalendarTile(
          calendarDetails: ownedCalendars[index],
        );
      },
    );
  }
}
