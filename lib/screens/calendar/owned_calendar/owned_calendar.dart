import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/request.dart';
import 'package:blok_p1/models/time_slot.dart';
import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/arguments.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/calendar/owned_sfcalendar.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/menu/follower_tile.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/menu/join_calendar_request_tile.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/menu/join_time_slot_request_tile.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/menu/menu.dart';
import 'package:blok_p1/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OwnedCalendarPage extends StatefulWidget {
  static const route = '/calendar/owned';
  @override
  _OwnedCalendarPageState createState() => _OwnedCalendarPageState();
}

class _OwnedCalendarPageState extends State<OwnedCalendarPage> {
  TimeSlots _timeSlots = TimeSlots(timeSlots: {});
  bool _isEditing = false;

  void _updateTimeSlots() {}

  @override
  Widget build(BuildContext context) {
    final OwnedCalendarArguments args =
        ModalRoute.of(context).settings.arguments;
    final FirebaseUser firebaseUser = Provider.of<FirebaseUser>(context);

    return MultiProvider(
      providers: [
        StreamProvider<User>.value(
          value: DatabaseService().streamUser(firebaseUser.uid),
        ),
        StreamProvider<Calendar>.value(
          value: DatabaseService().streamCalendar(args.calendarId),
        ),
        StreamProvider<TimeSlots>.value(
          value: DatabaseService()
              .streamTimeSlots(args.calendarId, CalendarType.OWNER),
        )
      ],
      builder: (context, child) {
        final User user = Provider.of<User>(context);
        final Calendar calendar = Provider.of<Calendar>(context);

        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   print('rebuild');
        //   timeSlots.updateSources(timeSlots, calendar.granularity);
        // });

        return Scaffold(
          endDrawer: OwnedCalendarMenu(),
          appBar: AppBar(
            title: Text(calendar == null
                ? ''
                : _isEditing
                    ? 'Editing: ' + calendar.name
                    : calendar.name),
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
                                return OwnedCalendarJoinTimeSlotRequestTile(
                                  request: pendingTimeSlotRequests[index],
                                  approverUserId: firebaseUser.uid,
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
              SizedBox(
                width: 50.0,
                child: FlatButton(
                    onPressed: () async {
                      // get the followers here
                      List<Request> pendingJoinRequests = calendar != null
                          ? calendar.requests.entries
                              .map((e) => Request(
                                  requestId: e.key, requesterId: e.value))
                              .toList()
                          : [];
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListView.builder(
                              itemCount: pendingJoinRequests.length,
                              itemBuilder: (context, index) {
                                return OwnedCalendarJoinCalendarRequestTile(
                                  request: pendingJoinRequests[index],
                                  approverUserId: firebaseUser.uid,
                                );
                              },
                            );
                          });
                    },
                    child: Icon(
                      Icons.person_add_alt_1,
                      size: 25.0,
                    )),
              ),
              SizedBox(
                width: 50.0,
                child: FlatButton(
                    onPressed: () async {
                      // get the followers here
                      List<User> followers = calendar != null
                          ? calendar.followers.entries
                              .map((e) =>
                                  User(userId: e.key, displayName: e.value))
                              .toList()
                          : [];
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListView.builder(
                              itemCount: followers.length,
                              itemBuilder: (context, index) {
                                return OwnedCalendarFollowerTile(
                                    user: followers[index],
                                    calendarId: calendar.calendarId);
                              },
                            );
                          });
                    },
                    child: Icon(
                      Icons.people,
                      size: 25.0,
                    )),
              ),
              SizedBox(
                width: 50.0,
                child: FlatButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    child: _isEditing
                        ? Icon(
                            Icons.edit_off,
                            size: 25.0,
                          )
                        : Icon(Icons.edit, size: 25.0)),
              ),
            ],
          ),
          body: OwnedSfCalendar(),
        );
      },
    );
  }
}
