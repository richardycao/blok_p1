import 'dart:math';

import 'package:blok_p1/constants/testing_constants.dart';
import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/time_slot.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/owned_calendar_arguments.dart';
import 'package:blok_p1/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class OwnedCalendarPage extends StatelessWidget {
  static const route = '/calendar/owned';
  @override
  Widget build(BuildContext context) {
    final OwnedCalendarArguments args =
        ModalRoute.of(context).settings.arguments;

    DateTime now = DateTime.now();

    return MultiProvider(
      providers: [
        StreamProvider<Calendar>.value(
          value: DatabaseService(calendarId: args.calendarId).streamCalendar(),
        ),
        StreamProvider<TimeSlots>.value(
          value: DatabaseService(calendarId: args.calendarId)
              .streamTimeSlots(CalendarType.OWNER),
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
                    await DatabaseService(
                            userId:
                                testRemoveUserId, // hardcoded for testing for now
                            calendarId: calendar.calendarId)
                        .leaveCalendar();
                  },
                  icon: Icon(Icons.arrow_circle_up),
                  label: Text('remU')), // remove hardcoded user
              FlatButton.icon(
                  onPressed: () async {
                    await DatabaseService(calendarId: calendar.calendarId)
                        .updateCalendarData(
                            description:
                                Random.secure().nextInt(10000).toString());
                  },
                  icon: Icon(Icons.arrow_circle_up),
                  label: Text(
                      'upd')), // update calendar description with random number
              FlatButton.icon(
                  onPressed: () async {
                    // delete the calendar and pop from navigator
                  },
                  icon: Icon(Icons.delete),
                  label: Text('del')), // delete calendar
            ],
          ),
          body: Container(
            child: SfCalendar(
              // minDate and maxDate prevent scrolling to previous dates (limits visibility)

              // for paying server, min will be the day they started
              // for nonpaying server, min will be the day they started
              // for client, min will be the day they joined.

              // for paying server, max will be 1 year in the future
              // for nonpaying server, max will be 1 month in the future
              // for client, max will be same as the calendar's server

              // specialRegions can make time slots uninteractable
              // for all, time slots from minDate to present are uninteractable
              // the server can choose which future time slots are interactable
              minDate: DateTime(now.year, now.month, now.day).add(Duration(
                  days: calendar != null ? calendar.backVisibility : 0)),
              maxDate: DateTime(now.year, now.month, now.day).add(Duration(
                  days: calendar != null ? calendar.forwardVisibility : 0)),
              dataSource: timeSlots,
              onTap: (CalendarTapDetails details) async {
                DateTime dt = details.appointments == null
                    ? details.date
                    : details.appointments[0].from;
                String timeSlotId = calendar.constructTimeSlotId(dt);

                if (timeSlots == null) {
                  // do nothing
                } else if (timeSlots.timeSlots.containsKey(timeSlotId)) {
                  int status =
                      timeSlots.timeSlots[timeSlotId].status == 0 ? 1 : 0;
                  await DatabaseService(
                          calendarId: calendar.calendarId,
                          timeSlotId: timeSlotId)
                      .updateTimeSlotData(status: status);
                } else {
                  print('out of range');
                }
              },
              view: CalendarView.day, // move this to calendar settings later
              //specialRegions: _unavailableTimeSlots(), // move this to calendar settings later
              timeSlotViewSettings: TimeSlotViewSettings(
                  // move this to calendar settings later
                  timeInterval: calendar != null
                      ? Duration(minutes: calendar.granularity)
                      : const Duration(minutes: 60),
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
