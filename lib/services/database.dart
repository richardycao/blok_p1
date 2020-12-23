import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String userId;
  DatabaseService({this.userId});

  final CollectionReference userCollection =
      Firestore.instance.collection('users');
  final CollectionReference calendarCollection =
      Firestore.instance.collection('calendars');

  // CREATE user
  Future createUser({String displayName = "Guest", String email}) async {
    return await userCollection.document(userId).setData({
      'displayName': displayName,
      'email': email,
      'ownedCalendars': {},
      'followedCalendars': {},
    });
  }

  // UPDATE user data
  Future updateUserData({String displayName, String email}) async {
    return await userCollection.document(userId).setData({
      'displayName': displayName,
      'email': email,
    }, merge: true);
  }

  // CREATE calendar
  Future createCalendar(String name) async {
    try {
      DocumentReference docRef = await calendarCollection.add({
        'name': name,
        'owners': [userId],
        'followers': [],
      });
      String calendarId = docRef.documentID;

      // Updates user's owned calendars
      DocumentSnapshot snapshot = await userCollection.document(userId).get();
      final Map<String, String> ownedCalendars =
          new Map<String, String>.from(snapshot.data['ownedCalendars']);
      ownedCalendars[calendarId] = name;
      userCollection.document(userId).setData({
        'ownedCalendars': ownedCalendars,
      }, merge: true);
    } catch (e) {
      print(e.toString());
    }
  }

  // JOIN calendar (sub-category of UPDATE calendar)
  Future joinCalendar(String calendarId) async {
    try {
      // Adds user to calenar's list of followers
      DocumentSnapshot calendarSnapshot =
          await calendarCollection.document(calendarId).get();
      List<String> followers = calendarSnapshot.data['followers']
          .map<String>((item) => item as String)
          .toList();
      followers.add(userId);
      calendarCollection.document(calendarId).setData({
        'followers': followers,
      }, merge: true);

      // Updates user's followed calendars
      DocumentSnapshot snapshot = await userCollection.document(userId).get();
      final Map<String, String> followedCalendars =
          new Map<String, String>.from(snapshot.data['followedCalendars']);
      followedCalendars[calendarId] = calendarSnapshot.data['name'] as String;
      userCollection.document(userId).setData({
        'followedCalendars': followedCalendars,
      }, merge: true);
    } catch (e) {
      print(e.toString());
    }
  }

  // UPDATE calendar
}
