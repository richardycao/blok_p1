import 'dart:math';

import 'package:blok_p1/constants/testing_constants.dart';
import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/time_slot.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/owned_calendar_appbar.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/owned_calendar_arguments.dart';
import 'package:blok_p1/screens/calendar/owned_calendar/owned_calendar_sf/owned_calendar_sf.dart';
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
  // List<TimeRegion> _unavailableTimeSlots() {
  //   final DateTime today = DateTime.now();
  //   final List<TimeRegion> regions = <TimeRegion>[];
  //   regions.add(TimeRegion(
  //       startTime: DateTime(today.year, today.month, today.day, 0, 0, 0),
  //       endTime: DateTime(today.year, today.month, today.day, 8, 0, 0),
  //       enablePointerInteraction: false,
  //       color: Colors.grey.withOpacity(0.5),
  //       text: ''));
  //   regions.add(TimeRegion(
  //       startTime: DateTime(today.year, today.month, today.day, 18, 0, 0),
  //       endTime: DateTime(today.year, today.month, today.day, 24, 0, 0),
  //       enablePointerInteraction: false,
  //       color: Colors.grey.withOpacity(0.5),
  //       text: ''));

  //   return regions;
  // }

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
        final TimeSlots timeSlots = Provider.of<TimeSlots>(context);

        return Scaffold(
          appBar: OwnedCalendarAppBar(),
          body: Container(
            child: OwnedCalendarSf(timeSlots: timeSlots),
          ),
        );
      },
    );
  }
}
