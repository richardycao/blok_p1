import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/request.dart';
import 'package:blok_p1/models/time_slot.dart';
import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/screens/calendar/followed_calendar/followed_calendar_arguments.dart';
import 'package:blok_p1/screens/calendar/followed_calendar/followed_calendar_join_time_slot_request_tile.dart';
import 'package:blok_p1/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class FollowedCalendarPage extends StatelessWidget {
  static const route = '/calendar/followed';

  @override
  Widget build(BuildContext context) {
    final FollowedCalendarArguments args =
        ModalRoute.of(context).settings.arguments;
    final FirebaseUser firebaseUser = Provider.of<FirebaseUser>(context);

    DateTime now = DateTime.now();

    return MultiProvider(
        providers: [
          StreamProvider<User>.value(
            value: DatabaseService(userId: firebaseUser.uid).streamUser(),
          ),
          StreamProvider<Calendar>.value(
            value:
                DatabaseService(calendarId: args.calendarId).streamCalendar(),
          ),
          StreamProvider<TimeSlots>.value(
            value: DatabaseService(calendarId: args.calendarId)
                .streamTimeSlots(CalendarType.CLIENT),
          )
        ],
        builder: (context, child) {
          final User user = Provider.of<User>(context);
          final Calendar calendar = Provider.of<Calendar>(context);
          final TimeSlots timeSlots = Provider.of<TimeSlots>(context);

          return Scaffold(
            appBar: AppBar(
              title: Text(calendar == null ? '' : calendar.name),
              actions: [
                SizedBox(
                  width: 50.0,
                  child: FlatButton(
                      onPressed: () async {
                        // get the time slot requests here
                        // i.e. gets incomingRequests for the calendar's owner
                        List<Request> pendingTimeSlotRequests = user != null
                            ? user.incomingRequests.entries
                                .where((element) =>
                                    element.value.split("-")[0] ==
                                        calendar.calendarId &&
                                    element.value.split("-").length > 1)
                                .map((e) => Request(
                                    requestId: e.key, requesterId: e.value))
                                .toList()
                            : [];
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return ListView.builder(
                                itemCount: pendingTimeSlotRequests.length,
                                itemBuilder: (context, index) {
                                  // return Text(pendingTimeSlotRequests[index]
                                  //     .requesterName);
                                  return FollowedCalendarJoinTimeSlotRequestsTile(
                                    request: pendingTimeSlotRequests[index],
                                    approverId: firebaseUser.uid,
                                  );
                                },
                              );
                            });
                      },
                      child: Icon(
                        Icons.pending_actions,
                        size: 25.0,
                      )),
                ),
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
                  if (timeSlots == null) {
                    // do nothing
                  } else if (timeSlots.timeSlots.containsKey(timeSlotId)) {
                    // if it's a valid time slot
                    if (timeSlots.timeSlots[timeSlotId].status != 0) {
                      // if the time slot is available
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              child: Column(
                                children: [
                                  Text(
                                      "Occupants: ${timeSlots.timeSlots[timeSlotId].occupants.length} / ${timeSlots.timeSlots[timeSlotId].limit}"),
                                  RaisedButton(
                                      child: timeSlots
                                              .timeSlots[timeSlotId].occupants
                                              .containsKey(firebaseUser.uid)
                                          ? Text('Leave')
                                          :
                                          // timeSlots.timeSlots[timeSlotId]
                                          //             .occupants.length <
                                          //         timeSlots
                                          //             .timeSlots[timeSlotId]
                                          //             .limit
                                          //     ?
                                          Text('Join/request'),
                                      //: Text("it's full"),
                                      onPressed: () async {
                                        if (timeSlots
                                            .timeSlots[timeSlotId].occupants
                                            .containsKey(firebaseUser.uid)) {
                                          // if the user is already an occupant
                                          print('is occupant, now leaving');
                                          await DatabaseService(
                                                  userId: firebaseUser.uid,
                                                  calendarId:
                                                      calendar.calendarId,
                                                  timeSlotId: timeSlotId)
                                              .leaveTimeSlot();
                                        } else
                                        // if (timeSlots
                                        //         .timeSlots[timeSlotId]
                                        //         .occupants
                                        //         .length <
                                        //     timeSlots
                                        //         .timeSlots[timeSlotId].limit)
                                        {
                                          // if the user is not yet an occupant and the time slot is not full
                                          print('not occupant, now requesting');
                                          await DatabaseService(
                                                  userId: firebaseUser.uid,
                                                  calendarId:
                                                      calendar.calendarId,
                                                  timeSlotId: timeSlotId)
                                              .createRequestJoinTimeSlot(
                                                  timeSlots
                                                      .timeSlots[timeSlotId]
                                                      .eventName);
                                        }
                                        // else {
                                        //   // if the user tries to join the time slot but it's full
                                        //   print(
                                        //       'not occupant, time slot is full');
                                        // }
                                        Navigator.pop(context);
                                      }),
                                ],
                              ),
                            );
                          });
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
