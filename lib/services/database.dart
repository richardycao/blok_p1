import 'dart:math';

import 'package:blok_p1/constants/auth_constants.dart';
import 'package:blok_p1/constants/database_constants.dart';
import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/time_slot.dart';
import 'package:blok_p1/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  String userId;
  String calendarId;
  DatabaseService({this.userId, this.calendarId});

  final CollectionReference userCollection =
      Firestore.instance.collection('users');
  final CollectionReference calendarCollection =
      Firestore.instance.collection('calendars');

  Stream<User> streamUser() {
    try {
      return userCollection
          .document(userId)
          .snapshots()
          .map((snapshot) => User.fromSnapshot(snapshot));
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<Calendar> streamCalendar() {
    try {
      return calendarCollection
          .document(calendarId)
          .snapshots()
          .map((snapshot) => Calendar.fromSnapshot(snapshot));
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<TimeSlots> streamTimeSlots() {
    try {
      return calendarCollection
          .document(calendarId)
          .collection('timeSlots')
          .snapshots()
          .map((snapshot) => TimeSlots.fromSnapshot(snapshot));
    } catch (e) {
      print(e);
      return null;
    }
  }

  // CREATE user
  Future createUser(
      {String displayName = anon_name,
      String email,
      bool serverEnabled = false}) async {
    return await userCollection.document(userId).setData({
      'displayName': displayName,
      'email': email,
      'ownedCalendars': {},
      'followedCalendars': {},
      'serverEnabled': serverEnabled,
    });
  }

  // UPDATE user data
  Future updateUserData(
      {String displayName, String email, bool serverEnabled}) async {
    await userCollection.document(userId).setData({
      if (displayName != null) 'displayName': displayName,
      if (email != null) 'email': email,
      if (serverEnabled != null) 'serverEnabled': serverEnabled,
    }, merge: true);
  }

  // CREATE calendar
  Future createCalendar(String name,
      {String description = calendar_description,
      int backVisiblity = -1,
      int forwardVisibility = 1}) async {
    try {
      // Creates calendar
      DocumentReference docRef = await calendarCollection.add({
        'name': name,
        'description': description,
        'owners': [userId],
        'followers': [],
        'backVisibility': backVisiblity,
        'forwardVisibility': forwardVisibility,
      });
      String calendarId = docRef.documentID;

      // Add time slots
      DateTime now = DateTime.now();
      DateTime start = now.add(Duration(days: backVisiblity));
      DateTime end = now.add(Duration(days: forwardVisibility));
      final timeDiff = end.difference(start).inHours;
      List<DateTime> timeSlots = List.generate(
          timeDiff,
          (i) =>
              DateTime(start.year, start.month, start.day, start.hour + (i)));

      CollectionReference timeSlotsCollection = Firestore.instance
          .collection('calendars')
          .document(calendarId)
          .collection('timeSlots');

      timeSlots.forEach((ts) async {
        String timeSlotId =
            calendarId + Timestamp.fromDate(ts).seconds.toString();
        await timeSlotsCollection.document(timeSlotId).setData({
          'timeSlotId': timeSlotId,
          'start': ts,
          'status': 0,
        });
      });

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

  // UPDATE calendar data
  Future updateCalendarData({String name, String description}) async {
    await calendarCollection.document(calendarId).setData({
      if (name != null) 'name': name,
      if (description != null) 'description': description,
    }, merge: true);
  }

  // UPDATE time slot data
  Future updateTimeSlotData(String timeSlotId) async {
    await calendarCollection
        .document(calendarId)
        .collection('timeSlots')
        .document(timeSlotId)
        .setData({
      'status': Random.secure().nextInt(10000),
    }, merge: true);
  }
}
