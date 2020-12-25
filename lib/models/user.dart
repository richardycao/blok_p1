import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  String displayName;
  String email;
  Map<String, String> ownedCalendars;
  Map<String, String> followedCalendars;
  bool serverEnabled;

  User({
    this.userId,
    this.displayName,
    this.email,
    this.ownedCalendars,
    this.followedCalendars,
    this.serverEnabled,
  });

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    Map data = snapshot.data;
    data = data ?? {};
    return User(
      userId: snapshot.documentID ?? null,
      displayName: data['displayName'] as String ?? null,
      email: data['email'] as String ?? null,
      ownedCalendars: Map<String, String>.from(data['ownedCalendars']) ?? {},
      followedCalendars:
          Map<String, String>.from(data['followedCalendars']) ?? {},
      serverEnabled: data['serverEnabled'] as bool ?? null,
    );
  }
}
