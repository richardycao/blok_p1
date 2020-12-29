import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/time_slot.dart';
import 'package:blok_p1/screens/calendar/followed_calendar/followed_calendar_arguments.dart';
import 'package:blok_p1/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class FollowedCalendar extends StatefulWidget {
  static const route = '/calendar/followed';

  @override
  _FollowedCalendarState createState() => _FollowedCalendarState();
}

class _FollowedCalendarState extends State<FollowedCalendar> {
  @override
  Widget build(BuildContext context) {
    final FollowedCalendarArguments args =
        ModalRoute.of(context).settings.arguments;

    DateTime now = DateTime.now();

    return MultiProvider(
        providers: [
          StreamProvider<Calendar>.value(
            value:
                DatabaseService(calendarId: args.calendarId).streamCalendar(),
          ),
          StreamProvider<TimeSlots>.value(
            value:
                DatabaseService(calendarId: args.calendarId).streamTimeSlots(),
          )
        ],
        builder: (context, child) {
          final FirebaseUser firebaseUser = Provider.of<FirebaseUser>(context);
          final Calendar calendar = Provider.of<Calendar>(context);
          final TimeSlots timeSlots = Provider.of<TimeSlots>(context);

          return Scaffold(
            appBar: AppBar(
              title: Text(calendar == null ? '' : calendar.name),
              actions: [
                FlatButton.icon(
                    onPressed: () async {
                      await DatabaseService(
                              userId: firebaseUser.uid,
                              calendarId: calendar.calendarId)
                          .leaveCalendar();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.exit_to_app),
                    label: Text('leave')),
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
                  print('====================');
                  if (timeSlots == null) {
                    // do nothing
                  } else if (timeSlots.timeSlots.containsKey(timeSlotId)) {
                    // if it's a valid time slot
                    if (timeSlots.timeSlots[timeSlotId].status != 0) {
                      // if the time slot is available
                      print('available');
                      if (timeSlots.timeSlots[timeSlotId].occupants
                          .containsKey(firebaseUser.uid)) {
                        // if the user is already an occupant
                        print('is occupant, now leaving');
                        await DatabaseService(
                                userId: firebaseUser.uid,
                                calendarId: calendar.calendarId,
                                timeSlotId: timeSlotId)
                            .leaveTimeSlot();
                      } else if (timeSlots
                              .timeSlots[timeSlotId].occupants.length <
                          timeSlots.timeSlots[timeSlotId].limit) {
                        // if the user is not yet an occupant and the time slot is not full
                        print('not occupant, now joining');
                        await DatabaseService(
                                userId: firebaseUser.uid,
                                calendarId: calendar.calendarId,
                                timeSlotId: timeSlotId)
                            .joinTimeSlot();
                      } else {
                        // if the user tries to join the time slot but it's full
                        print('not occupant, time slot is full');
                      }
                    } else {
                      print('unavailable');
                    }
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
        });
  }
}
