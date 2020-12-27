import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TimeSlot {
  final String timeSlotId;
  // status: unavailable, open, closed
  int status;
  // start_time: start time
  final DateTime startTime;
  // end_time: end time
  //           (maybe not necessary since time slots are identified by start time in the sfcalendar.
  //            the end time is implied by the appointment duration.)
  // occupants: list of booked Users
  // limit: max # of people allowed

  TimeSlot({
    this.timeSlotId,
    this.startTime,
    this.status,
  });
}

class TimeSlots {
  Map<String, TimeSlot> timeSlots;

  TimeSlots({this.timeSlots});

  factory TimeSlots.fromSnapshot(QuerySnapshot querySnapshot) {
    List<DocumentSnapshot> snapshots = querySnapshot.documents.toList();
    snapshots = snapshots ?? {};
    return TimeSlots(
        timeSlots: Map.fromIterable(
      snapshots,
      key: (snap) => snap.documentID,
      value: (snap) {
        return TimeSlot(
          timeSlotId: snap.documentID,
          startTime: snap.data['start'].toDate() ??
              null, // snap.data['start'] arrives as Timestamp
          status: snap.data['status'] ?? null,
        );
      },
    ));
  }

  List<Meeting> getDataSources(int granularity) {
    return timeSlots.entries
        .where((element) => element.value.status == 1)
        .map((entry) {
      return Meeting(
          entry.value.timeSlotId,
          entry.value.startTime,
          entry.value.startTime.add(Duration(minutes: granularity)),
          Colors.red,
          false);
    }).toList();
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
