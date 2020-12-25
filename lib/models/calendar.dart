import 'package:cloud_firestore/cloud_firestore.dart';

class Calendar {
  final String calendarId;
  String name;
  String description;
  List<String> owners;
  List<String> followers;

  Calendar(
      {this.calendarId,
      this.name,
      this.description,
      this.owners,
      this.followers});

  factory Calendar.fromSnapshot(DocumentSnapshot snapshot) {
    Map data = snapshot.data;
    data = data ?? {};
    return Calendar(
      calendarId: snapshot.documentID ?? null,
      name: data['name'] as String ?? null,
      description: data['description'] as String ?? null,
      owners: List<String>.from(data['owners']) ?? {},
      followers: List<String>.from(data['followers']) ?? {},
    );
  }
}
