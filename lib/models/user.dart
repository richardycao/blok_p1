import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  String displayName;
  String email;
  Map<String, String> ownedCalendars;
  Map<String, String> followedCalendars;
  bool serverEnabled;
  Map<String, String> bookings;
  Map<String, String> incomingRequests;
  Map<String, String> outgoingRequests;

  User({
    this.userId,
    this.displayName,
    this.email,
    this.ownedCalendars,
    this.followedCalendars,
    this.serverEnabled,
    this.bookings,
    this.incomingRequests,
    this.outgoingRequests,
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
      bookings: Map<String, String>.from(data['bookings']) ?? {},
      incomingRequests:
          Map<String, String>.from(data['incomingRequests']) ?? {},
      outgoingRequests:
          Map<String, String>.from(data['outgoingRequests']) ?? {},
    );
  }
}
