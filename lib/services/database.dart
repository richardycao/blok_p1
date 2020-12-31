import 'package:blok_p1/constants/testing_constants.dart';
import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/time_slot.dart';
import 'package:blok_p1/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static const String USERS = 'users';
  static const String CALENDARS = 'calendars';
  static const String TIMESLOTS = 'timeSlots';

  String userId;
  String calendarId;
  String timeSlotId;
  DatabaseService({this.userId, this.calendarId, this.timeSlotId});

  final CollectionReference userCollection =
      Firestore.instance.collection(USERS);
  final CollectionReference calendarCollection =
      Firestore.instance.collection(CALENDARS);

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

  Stream<TimeSlots> streamTimeSlots(CalendarType type) {
    try {
      return calendarCollection
          .document(calendarId)
          .collection(TIMESLOTS)
          .snapshots()
          .map((snapshot) => TimeSlots.fromQuerySnapshot(snapshot, type));
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
    await userCollection.document(userId).setData({
      'displayName': displayName,
      'email': email,
      'ownedCalendars': {},
      'followedCalendars': {},
      'serverEnabled': serverEnabled,
      'bookings': {},
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
  Future<String> createCalendar(String name,
      {String description = calendar_description,
      int backVisiblity = 0,
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
      String newCalendarId = docRef.documentID;

      // Add time slots
      DateTime start = today.add(Duration(days: backVisiblity));
      DateTime end = today.add(Duration(days: forwardVisibility));
      final timeDiff = end.difference(start).inHours;
      List<DateTime> timeSlots = List.generate(
          timeDiff,
          (i) => DateTime(
              start.year, start.month, start.day, start.hour + (i), 0, 0));

      CollectionReference timeSlotsCollection =
          calendarCollection.document(newCalendarId).collection(TIMESLOTS);

      timeSlots.forEach((ts) async {
        String timeSlotId =
            Calendar(calendarId: newCalendarId).constructTimeSlotId(ts);
        await timeSlotsCollection.document(timeSlotId).setData({
          //'timeSlotId': timeSlotId,
          'eventName': null,
          'status': 0,
          'occupants': {},
          'limit': testTimeSlotLimit,
          'from': ts,
          'to': ts.add(Duration(minutes: granularity)),
          'background': null,
          'isAllDay': null,
        });
      });

      // Updates user's owned calendars
      await userCollection.document(userId).updateData({
        "ownedCalendars.$newCalendarId": name,
      });

      return newCalendarId;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // JOIN calendar (sub-category of UPDATE calendar)
  Future joinCalendar() async {
    try {
      DocumentSnapshot calendarSnapshot =
          await calendarCollection.document(calendarId).get();

      // Adds user to calendar's list of followers
      await calendarCollection.document(calendarId).updateData({
        "followers.$userId": temp_name,
      });

      // Updates user's followed calendars
      await userCollection.document(userId).updateData({
        "followedCalendars.$calendarId":
            calendarSnapshot.data['name'] as String,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // LEAVE calendar or REMOVE from calendar
  Future leaveCalendar() async {
    try {
      DocumentSnapshot userSnapshot =
          await userCollection.document(userId).get();

      // Remove user from all the calendar's time slots
      List<String> timeSlotIdsToClear =
          Map<String, String>.from(userSnapshot.data['bookings'])
              .entries
              .where((element) => element.value == calendarId)
              .map((element) => element.key)
              .toList();
      timeSlotIdsToClear.forEach((tsId) async {
        Map<String, Object> deleteUserId = {};
        deleteUserId["occupants.$userId"] = FieldValue.delete();
        await calendarCollection
            .document(calendarId)
            .collection(TIMESLOTS)
            .document(tsId)
            .updateData(deleteUserId);
      });

      // Removes user from calendar's list of followers
      Map<String, Object> deleteFollowerId = {};
      deleteFollowerId["followers.$userId"] = FieldValue.delete();
      print(userId);
      await calendarCollection
          .document(calendarId)
          .updateData(deleteFollowerId);

      // Updates user's followed calendars and bookings
      Map<String, String> bookings =
          new Map<String, String>.from(userSnapshot.data['bookings']);
      final Map<String, String> followedCalendars =
          new Map<String, String>.from(userSnapshot.data['followedCalendars']);
      bookings = Map<String, String>.fromEntries(
          bookings.entries.where((element) => element.value != calendarId));
      followedCalendars.remove(calendarId);
      await userCollection.document(userId).setData({
        'bookings': bookings,
        'followedCalendars': followedCalendars,
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

  // JOIN time slot
  Future joinTimeSlot(String name) async {
    try {
      // Adds user to time slot's occupants
      await calendarCollection
          .document(calendarId)
          .collection(TIMESLOTS)
          .document(timeSlotId)
          .updateData({
        "occupants.$userId": name,
      });

      // Updates user's bookings
      await userCollection.document(userId).updateData({
        "bookings.$timeSlotId":
            calendarId, //timeSlotSnapshot.data['eventName'] as String, <- this is null btw
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // LEAVE time slot
  Future leaveTimeSlot() async {
    try {
      // Updates user's bookings
      Map<String, Object> deleteTimeSlotId = {};
      deleteTimeSlotId["bookings.$timeSlotId"] = FieldValue.delete();
      await userCollection.document(userId).updateData(deleteTimeSlotId);

      // Removes user to time slot's occupants
      Map<String, Object> deleteUserId = {};
      deleteUserId["occupants.$userId"] = FieldValue.delete();
      await calendarCollection
          .document(calendarId)
          .collection(TIMESLOTS)
          .document(timeSlotId)
          .updateData(deleteUserId);
    } catch (e) {
      print(e.toString());
    }
  }

  // KICK from time slot
  Future kickFromTimeSlot(String kickedUserId) async {
    try {
      // Updates user's bookings
      Map<String, Object> deleteTimeSlotId = {};
      deleteTimeSlotId["bookings.$timeSlotId"] = FieldValue.delete();
      await userCollection.document(kickedUserId).updateData(deleteTimeSlotId);

      // Removes user to time slot's occupants
      Map<String, Object> deleteUserId = {};
      deleteUserId["occupants.$kickedUserId"] = FieldValue.delete();
      await calendarCollection
          .document(calendarId)
          .collection(TIMESLOTS)
          .document(timeSlotId)
          .updateData(deleteUserId);
    } catch (e) {
      print(e.toString());
    }
  }

  // UPDATE time slot data
  Future updateTimeSlotData({int status}) async {
    if (status == 0) {
      DocumentSnapshot snapshot = await calendarCollection
          .document(calendarId)
          .collection(TIMESLOTS)
          .document(timeSlotId)
          .get();
      Map<String, String> occupants =
          Map<String, String>.from(snapshot.data['occupants']);
      // leave time slot for each occupant
      occupants.forEach((key, value) async {
        await kickFromTimeSlot(key);
      });
    }
    await calendarCollection
        .document(calendarId)
        .collection(TIMESLOTS)
        .document(timeSlotId)
        .setData({
      if (status != null) 'status': status,
    }, merge: true);
  }
}
