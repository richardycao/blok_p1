import 'package:blok_p1/models/time_slot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Calendar {
  final String calendarId;
  String name;
  String description;
  List<String> owners;
  List<String> followers;
  int backVisibility;
  int forwardVisibility;

  Calendar(
      {this.calendarId,
      this.name,
      this.description,
      this.owners,
      this.followers,
      this.backVisibility,
      this.forwardVisibility});

  factory Calendar.fromSnapshot(DocumentSnapshot snapshot) {
    // check if updating a time slot will trigger a calendar update
    // -> it doesn't
    Map data = snapshot.data;
    data = data ?? {};
    return Calendar(
      calendarId: snapshot.documentID ?? null,
      name: data['name'] as String ?? null,
      description: data['description'] as String ?? null,
      owners: List<String>.from(data['owners']) ?? {},
      followers: List<String>.from(data['followers']) ?? {},
      backVisibility: data['backVisibility'] as int ?? null,
      forwardVisibility: data['forwardVisibility'] as int ?? null,
    );
  }

  String getTimeSlotId(DateTime dt) {
    return calendarId + Timestamp.fromDate(dt).seconds.toString();
  }
}
