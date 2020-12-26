import 'package:cloud_firestore/cloud_firestore.dart';

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
}
