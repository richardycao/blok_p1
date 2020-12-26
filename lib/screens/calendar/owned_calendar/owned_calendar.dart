import 'dart:math';

import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/time_slot.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/owned_calendar_arguments.dart';
import 'package:blok_p1/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class OwnedCalendar extends StatefulWidget {
  static const route = '/calendar/owned';

  @override
  _OwnedCalendarState createState() => _OwnedCalendarState();
}

class _OwnedCalendarState extends State<OwnedCalendar> {
  List<TimeRegion> _unavailableTimeSlots() {
    final DateTime today = DateTime.now();
    final List<TimeRegion> regions = <TimeRegion>[];
    regions.add(TimeRegion(
        startTime: DateTime(today.year, today.month, today.day, 0, 0, 0),
        endTime: DateTime(today.year, today.month, today.day, 8, 0, 0),
        enablePointerInteraction: false,
        color: Colors.grey.withOpacity(0.5),
        text: ''));
    regions.add(TimeRegion(
        startTime: DateTime(today.year, today.month, today.day, 18, 0, 0),
        endTime: DateTime(today.year, today.month, today.day, 24, 0, 0),
        enablePointerInteraction: false,
        color: Colors.grey.withOpacity(0.5),
        text: ''));

    return regions;
  }

  @override
  Widget build(BuildContext context) {
    final OwnedCalendarArguments args =
        ModalRoute.of(context).settings.arguments;

    return MultiProvider(
      providers: [
        StreamProvider<Calendar>.value(
          value: DatabaseService(calendarId: args.calendarId).streamCalendar(),
        ),
        StreamProvider<TimeSlots>.value(
          value: DatabaseService(calendarId: args.calendarId).streamTimeSlots(),
        )
      ],
      builder: (context, child) {
        final Calendar calendar = Provider.of<Calendar>(context);
        final TimeSlots timeSlots = Provider.of<TimeSlots>(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(calendar == null ? '' : calendar.name),
            actions: <Widget>[
              FlatButton.icon(
                  onPressed: () async {
                    await DatabaseService(calendarId: calendar.calendarId)
                        .updateCalendarData(
                            description:
                                Random.secure().nextInt(10000).toString());
                  },
                  icon: Icon(Icons.arrow_circle_up),
                  label: Text('update calendar data')),
            ],
          ),
          body: Container(
            child: SfCalendar(
              onTap: (details) {
                String timeSlotId = calendar.getTimeSlotId(details.date);
                print(timeSlots.timeSlots[timeSlotId].status);
              },
              view: CalendarView.day, // move this to calendar settings later
              specialRegions:
                  _unavailableTimeSlots(), // move this to calendar settings later
              timeSlotViewSettings: TimeSlotViewSettings(
                  // move this to calendar settings later
                  timeInterval: Duration(hours: 1),
                  timeIntervalHeight: 70,
                  startHour: 0,
                  endHour: 24,
                  nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday]),
            ),
          ),
        );
      },
    );
  }
}
