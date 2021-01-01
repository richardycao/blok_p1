import 'package:blok_p1/models/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TimeSlot {
  final String timeSlotId;
  String eventName;
  int status; // make this into a String later for better interpretability
  Map<String, String> occupants;
  int limit;
  DateTime from;
  DateTime to;
  Map<String, String> requests;
  bool requiresOwnerApproval;

  // Ignore these
  Color background;
  bool isAllDay;

  TimeSlot({
    this.timeSlotId,
    this.eventName,
    this.status,
    this.occupants,
    this.limit,
    this.from,
    this.to,
    this.requests,
    this.background,
    this.isAllDay,
    this.requiresOwnerApproval,
  });
}

class TimeSlots extends CalendarDataSource {
  Map<String, TimeSlot> timeSlots;

  TimeSlots({Map<String, TimeSlot> timeSlots}) {
    appointments =
        timeSlots != null ? timeSlots.entries.map((e) => e.value).toList() : [];
    this.timeSlots = timeSlots ?? {};
  }

  factory TimeSlots.fromDocumentSnapshots(
      List<DocumentSnapshot> snapshots, CalendarType type) {
    snapshots = snapshots ?? {};
    return TimeSlots(
        timeSlots: Map.fromIterable(
      snapshots,
      key: (snap) => snap.documentID,
      value: (snap) {
        return TimeSlot(
          timeSlotId: snap.documentID,
          eventName: "", //snap.data['eventName'] as String ?? snap.documentID,
          status: snap.data['status'] as int ?? null,
          occupants: Map<String, String>.from(snap.data['occupants']) ?? {},
          limit: snap.data['limit'] as int ?? null,
          from: snap.data['from'].toDate() ?? null,
          to: snap.data['to'].toDate() ?? null,
          requests: Map<String, String>.from(snap.data['requests']) ?? {},
          requiresOwnerApproval:
              snap.data['requiresOwnerApproval'] as bool ?? null,
          background: (snap.data['status'] as int) == 0
              ? Colors.grey
              : snap.data['occupants'].length > 0
                  ? Colors.red
                  : Colors.white,
          isAllDay: snap.data['isAllDay'] ?? false,
        );
      },
    ));
  }

  factory TimeSlots.fromQuerySnapshot(
      QuerySnapshot querySnapshot, CalendarType type) {
    List<DocumentSnapshot> snapshots = querySnapshot.documents.toList();
    return TimeSlots.fromDocumentSnapshots(snapshots, type);
  }

  factory TimeSlots.fromDocumentChanges(
      List<DocumentChange> documentChanges, CalendarType type) {
    List<DocumentSnapshot> snapshots =
        documentChanges.map((dc) => dc.document).toList();
    return TimeSlots.fromDocumentSnapshots(snapshots, type);
  }

  // update this.appointments with the document changes
  // void updateSources(TimeSlots ts, int granularity) {
  //   ts.timeSlots.entries.forEach((element) {
  //     timeSlots[element.key] = element.value;
  //   });
  //   appointments = timeSlots.entries.map((e) => e.value).toList();
  // }

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
