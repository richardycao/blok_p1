import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/time_slot.dart';
import 'package:blok_p1/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class OwnedCalendarSf extends StatefulWidget {
  final TimeSlots timeSlots;
  OwnedCalendarSf({this.timeSlots});

  @override
  _OwnedCalendarSfState createState() => _OwnedCalendarSfState();
}

class _OwnedCalendarSfState extends State<OwnedCalendarSf> {
  @override
  Widget build(BuildContext context) {
    final Calendar calendar = Provider.of<Calendar>(context);

    DateTime now = DateTime.now();
    return SfCalendar(
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
      minDate: DateTime(now.year, now.month, now.day)
          .add(Duration(days: calendar != null ? calendar.backVisibility : 0)),
      maxDate: DateTime(now.year, now.month, now.day).add(
          Duration(days: calendar != null ? calendar.forwardVisibility : 0)),
      dataSource: widget.timeSlots,
      onTap: (CalendarTapDetails details) async {
        DateTime dt = details.appointments == null
            ? details.date
            : details.appointments[0].from;
        String timeSlotId = calendar.constructTimeSlotId(dt);

        if (widget.timeSlots == null) {
          // do nothing
        } else if (widget.timeSlots.timeSlots.containsKey(timeSlotId)) {
          print('found id');
          int status =
              widget.timeSlots.timeSlots[timeSlotId].status == 0 ? 1 : 0;
          print(status);
          await DatabaseService(
                  calendarId: calendar.calendarId, timeSlotId: timeSlotId)
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
    );
  }
}
