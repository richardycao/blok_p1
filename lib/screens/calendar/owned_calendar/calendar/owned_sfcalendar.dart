import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/time_slot.dart';
import 'package:blok_p1/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class OwnedSfCalendar extends StatelessWidget {
  final bool isEditing;
  OwnedSfCalendar({this.isEditing});

  @override
  Widget build(BuildContext context) {
    final Calendar calendar = Provider.of<Calendar>(context);
    final TimeSlots timeSlots = Provider.of<TimeSlots>(context);

    DateTime now = DateTime.now();

    return Container(
      child: SfCalendar(
        view: CalendarView.week,
        minDate: DateTime(now.year, now.month, now.day).add(
            Duration(days: calendar != null ? calendar.backVisibility : 0)),
        maxDate: DateTime(now.year, now.month, now.day).add(
            Duration(days: calendar != null ? calendar.forwardVisibility : 0)),
        dataSource: timeSlots,
        onTap: isEditing == false
            ? null
            : (CalendarTapDetails details) async {
                DateTime dt = details.appointments == null
                    ? details.date
                    : details.appointments[0].from;
                String timeSlotId = calendar.constructTimeSlotId(dt);

                if (timeSlots == null) {
                  print('nothing');
                  // do nothing
                } else if (timeSlots.timeSlots.containsKey(timeSlotId)) {
                  print('update');
                  int status =
                      timeSlots.timeSlots[timeSlotId].status == 0 ? 1 : 0;
                  await DatabaseService().updateTimeSlot(
                      calendar.calendarId, timeSlots.timeSlots[timeSlotId],
                      status: status);
                } else {
                  print('out of range');
                }
              },
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
    );
  }
}
