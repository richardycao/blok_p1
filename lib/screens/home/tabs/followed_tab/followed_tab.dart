import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/screens/common/loading.dart';
import 'package:blok_p1/screens/home/tabs/followed_tab/followed_calendar_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowedCalendars extends StatefulWidget {
  @override
  _FollowedCalendarsState createState() => _FollowedCalendarsState();
}

class _FollowedCalendarsState extends State<FollowedCalendars> {
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    if (user == null) {
      return Loading(
        blank: true,
      );
    }

    final List<Calendar> followedCalendars =
        user.followedCalendars.entries.map((entry) {
      return Calendar(calendarId: entry.key, name: entry.value);
    }).toList();

    return ListView.builder(
      itemCount: followedCalendars.length,
      itemBuilder: (context, index) {
        return FollowedCalendarTile(
          calendarDetails: followedCalendars[index],
        );
      },
    );
  }
}
