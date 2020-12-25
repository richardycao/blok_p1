import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/owned_calendar_arguments.dart';
import 'package:blok_p1/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class OwnedCalendar extends StatefulWidget {
  static const route = '/calendar/owned';

  @override
  _OwnedCalendarState createState() => _OwnedCalendarState();
}

class _OwnedCalendarState extends State<OwnedCalendar> {
  @override
  Widget build(BuildContext context) {
    final OwnedCalendarArguments args =
        ModalRoute.of(context).settings.arguments;

    return StreamProvider<Calendar>.value(
        value: DatabaseService(calendarId: args.calendarId).streamCalendar(),
        builder: (context, child) {
          final Calendar calendar = Provider.of<Calendar>(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(calendar == null ? '' : calendar.name),
            ),
            body: Container(
              child: SfCalendar(),
            ),
          );
        });
  }
}
