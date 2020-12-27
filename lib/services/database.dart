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
  String timeSlotId;
  DatabaseService({this.userId, this.calendarId, this.timeSlotId});

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
      int forwardVisibility = 2,
      int granularity = 60}) async {
    try {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      // Creates calendar
      DocumentReference docRef = await calendarCollection.add({
        'name': name,
        'description': description,
        'owners': {userId: temp_name},
        'followers': {},
        'backVisibility': backVisiblity,
        'forwardVisibility': forwardVisibility,
        'createDate': now,
        'granularity': granularity,
      });
      String calendarId = docRef.documentID;

      // Add time slots
      DateTime start = today.add(Duration(days: backVisiblity));
      DateTime end = today.add(Duration(days: forwardVisibility));
      final timeDiff = end.difference(start).inHours;
      List<DateTime> timeSlots = List.generate(
          timeDiff,
          (i) => DateTime(
              start.year, start.month, start.day, start.hour + (i), 0, 0));

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
      await userCollection.document(userId).setData({
        'ownedCalendars': ownedCalendars,
      }, merge: true);
    } catch (e) {
      print(e.toString());
    }
  }

  // JOIN calendar (sub-category of UPDATE calendar)
  Future joinCalendar(String calendarId) async {
    try {
      DocumentSnapshot calendarSnapshot =
          await calendarCollection.document(calendarId).get();

      // Adds user to calendar's list of followers
      Map<String, String> followers =
          new Map<String, String>.from(calendarSnapshot.data['followers']);
      followers[userId] = temp_name;
      await calendarCollection.document(calendarId).setData({
        'followers': followers,
      }, merge: true);

      // Updates user's followed calendars
      DocumentSnapshot userSnapshot =
          await userCollection.document(userId).get();
      final Map<String, String> followedCalendars =
          new Map<String, String>.from(userSnapshot.data['followedCalendars']);
      followedCalendars[calendarId] = calendarSnapshot.data['name'] as String;
      await userCollection.document(userId).setData({
        'followedCalendars': followedCalendars,
      }, merge: true);
    } catch (e) {
      print(e.toString());
    }
  }

  // LEAVE calendar or REMOVE from calendar
  // uses own userId from the Provider
  // uses calendarId of the followed calendar from the Provider
  Future leaveCalendar() async {
    try {
      DocumentSnapshot calendarSnapshot =
          await calendarCollection.document(calendarId).get();

      // Updates user's followed calendars
      DocumentSnapshot userSnapshot =
          await userCollection.document(userId).get();
      final Map<String, String> followedCalendars =
          new Map<String, String>.from(userSnapshot.data['followedCalendars']);
      followedCalendars.remove(calendarId);
      await userCollection.document(userId).setData({
        'followedCalendars': followedCalendars,
      }, merge: true);

      // Removes user from calendar's list of followers
      Map<String, String> followers =
          new Map<String, String>.from(calendarSnapshot.data['followers']);
      followers.remove(userId);
      await calendarCollection.document(calendarId).setData({
        'followers': followers,
      }, merge: true);
    } catch (e) {
      print(e.toString());
    }
  }

  // UPDATE calendar data
  Future updateCalendarData(
      {String name, String description, int granularity}) async {
    await calendarCollection.document(calendarId).setData({
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (granularity != null) 'granularity': granularity,
    }, merge: true);
  }

  // DELETE calendar
  Future deleteCalendar() async {}

  // UPDATE time slot data
  Future updateTimeSlotData({int status}) async {
    await calendarCollection
        .document(calendarId)
        .collection('timeSlots')
        .document(timeSlotId)
        .setData({
      if (status != null) 'status': status,
    }, merge: true);
  }
}
