import 'package:cloud_firestore/cloud_firestore.dart';

class FollowedCalendar {
  final String calendarId;
  String name;
  Map<String, String> timeSlots;

  FollowedCalendar({this.calendarId, this.name, this.timeSlots});
}

class FollowedCalendars {
  Map<String, FollowedCalendar> followedCalendars;

  FollowedCalendars({Map<String, FollowedCalendar> followedCalendars}) {
    this.followedCalendars = followedCalendars ?? {};
  }

  factory FollowedCalendars.fromDocumentSnapshots(
      List<DocumentSnapshot> snapshots) {
    snapshots = snapshots ?? {};
    return FollowedCalendars(
      followedCalendars: Map.fromIterable(snapshots,
          key: (snap) => snap.documentID,
          value: (snap) {
            return FollowedCalendar(
              calendarId: snap.documentID,
              name: snap.data['name'],
              timeSlots: Map<String, String>.from(snap.data['timeSlots']) ?? {},
            );
          }),
    );
  }

  factory FollowedCalendars.fromQuerySnapshot(QuerySnapshot querySnapshot) {
    List<DocumentSnapshot> snapshots = querySnapshot.documents.toList();
    return FollowedCalendars.fromDocumentSnapshots(snapshots);
  }
}
