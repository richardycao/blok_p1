import 'dart:math';

import 'package:blok_p1/constants/testing_constants.dart';
import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/time_slot.dart';
import 'package:blok_p1/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OwnedCalendarAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final Calendar calendar = Provider.of<Calendar>(context);

    return AppBar(
      title: Text(calendar == null ? '' : calendar.name),
      actions: <Widget>[
        FlatButton.icon(
            onPressed: () async {
              await DatabaseService(
                      userId: testRemoveUserId, // hardcoded for testing for now
                      calendarId: calendar.calendarId)
                  .leaveCalendar();
            },
            icon: Icon(Icons.arrow_circle_up),
            label: Text('remU')), // remove hardcoded user
        FlatButton.icon(
            onPressed: () async {
              await DatabaseService(calendarId: calendar.calendarId)
                  .updateCalendarData(
                      description: Random.secure().nextInt(10000).toString());
            },
            icon: Icon(Icons.arrow_circle_up),
            label:
                Text('upd')), // update calendar description with random number
        FlatButton.icon(
            onPressed: () async {
              // delete the calendar and pop from navigator
            },
            icon: Icon(Icons.delete),
            label: Text('del')), // delete calendar
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
