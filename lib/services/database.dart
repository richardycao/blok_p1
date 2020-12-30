import 'package:blok_p1/constants/testing_constants.dart';
import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/followed_calendar.dart';
import 'package:blok_p1/models/time_slot.dart';
import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/screens/home/tabs/followed_tab/followed_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static const String USERS = 'users';
  static const String CALENDARS = 'calendars';
  static const String TIMESLOTS = 'timeSlots';
  //static const String FOLLOWED_CALENDARS = 'followedCalendars';

  //final String timeSlotsSub = 'timeSlots';
  //final String followedCalendarsSub = 'followedCalendars';
  //final String ownedCalendarsSub = 'ownedCalendars';

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

  // Stream<FollowedCalendars> streamUserCalendars() {
  //   try {
  //     return userCollection
  //         .document(userId)
  //         .collection(FOLLOWED_CALENDARS)
  //         .snapshots()
  //         .map((snapshot) => FollowedCalendars.fromQuerySnapshot(snapshot));
  //   } catch (e) {
  //     print(e);
  //     return null;
  //   }
  // }

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
    // CollectionReference timeSlotsCollection = Firestore.instance
    //       .collection('calendars')
    //       .document(calendarId)
    //       .collection(timeSlotsSub);
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
            newCalendarId + Timestamp.fromDate(ts).seconds.toString();
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
      DocumentSnapshot snapshot = await userCollection.document(userId).get();
      final Map<String, String> ownedCalendars =
          new Map<String, String>.from(snapshot.data['ownedCalendars']);
      ownedCalendars[newCalendarId] = name;
      await userCollection.document(userId).setData({
        'ownedCalendars': ownedCalendars,
      }, merge: true);

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
      // await userCollection
      //     .document(userId)
      //     .collection(FOLLOWED_CALENDARS)
      //     .document(calendarId)
      //     .setData({
      //   'name': calendarSnapshot.data['name'],
      //   'timeSlots': {},
      // });
    } catch (e) {
      print(e.toString());
    }
  }

  // LEAVE calendar or REMOVE from calendar
  // uses own userId from the Provider
  // uses calendarId of the followed calendar from the Provider
  Future leaveCalendar() async {
    try {
      DocumentSnapshot userSnapshot =
          await userCollection.document(userId).get();
      DocumentSnapshot calendarSnapshot =
          await calendarCollection.document(calendarId).get();

      // Remove user from all the calendar's time slots
      List<String> timeSlotIdsToClear =
          Map<String, String>.from(userSnapshot.data['bookings'])
              .entries
              .where((element) => element.value == calendarId)
              .map((element) => element.key)
              .toList();
      print(timeSlotIdsToClear);
      timeSlotIdsToClear.forEach((tsId) async {
        DocumentSnapshot timeSlotSnapshot = await calendarCollection
            .document(calendarId)
            .collection(TIMESLOTS)
            .document(tsId)
            .get();
        print(timeSlotSnapshot.documentID);
        final Map<String, String> occupants =
            new Map<String, String>.from(timeSlotSnapshot.data['occupants']);
        print(occupants);
        occupants.remove(userId);
        print(occupants);
        await calendarCollection
            .document(calendarId)
            .collection(TIMESLOTS)
            .document(tsId)
            .setData({
          'occupants': occupants,
        }, merge: true);
      });
      print('1');
      // DocumentSnapshot followedSnapshot = await userCollection
      //     .document(userId)
      //     .collection(FOLLOWED_CALENDARS)
      //     .document(calendarId)
      //     .get();
      // List<String> timeSlotIdsToDelete = followedSnapshot
      //     .data['timeSlots'].entries
      //     .map((entry) => entry.key as String)
      //     .toList();
      // timeSlotIdsToDelete.forEach((tsId) async {
      //   DocumentSnapshot timeSlotInCalendarSnapshot = await calendarCollection
      //       .document(calendarId)
      //       .collection(TIMESLOTS)
      //       .document(tsId)
      //       .get();
      //   Map<String, String> occupants = new Map<String, String>.from(
      //       timeSlotInCalendarSnapshot.data['occupants']);
      //   occupants.remove(userId);
      //   await calendarCollection
      //       .document(calendarId)
      //       .collection(TIMESLOTS)
      //       .document(tsId)
      //       .setData({
      //     'occupants': occupants,
      //   }, merge: true);
      // });

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
      print('2');
      // await userCollection
      //     .document(userId)
      //     .collection(FOLLOWED_CALENDARS)
      //     .document(calendarId)
      //     .delete();

      // Removes user from calendar's list of followers
      Map<String, String> followers =
          new Map<String, String>.from(calendarSnapshot.data['followers']);
      print(followers);
      followers.remove(userId);
      print(followers);
      await calendarCollection.document(calendarId).setData({
        'followers': followers,
      }, merge: true);
      print('3');
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
      DocumentSnapshot timeSlotSnapshot = await calendarCollection
          .document(calendarId)
          .collection(TIMESLOTS)
          .document(timeSlotId)
          .get();

      // Adds user to time slot's occupants
      Map<String, String> occupants =
          new Map<String, String>.from(timeSlotSnapshot.data['occupants']);
      occupants[userId] = name;
      await calendarCollection
          .document(calendarId)
          .collection(TIMESLOTS)
          .document(timeSlotId)
          .setData({
        'occupants': occupants,
      }, merge: true);

      // Updates user's bookings
      DocumentSnapshot userSnapshot =
          await userCollection.document(userId).get();
      final Map<String, String> bookings =
          new Map<String, String>.from(userSnapshot.data['bookings']);
      bookings[timeSlotId] =
          calendarId; //timeSlotSnapshot.data['eventName'] as String;
      await userCollection.document(userId).setData({
        'bookings': bookings,
      }, merge: true);
      // DocumentSnapshot followedSnapshot = await userCollection
      //     .document(userId)
      //     .collection(FOLLOWED_CALENDARS)
      //     .document(calendarId)
      //     .get();
      // final Map<String, String> timeSlots =
      //     new Map<String, String>.from(followedSnapshot.data['timeSlots']);
      // timeSlots[timeSlotId] = name;
      // await userCollection
      //     .document(userId)
      //     .collection(FOLLOWED_CALENDARS)
      //     .document(calendarId)
      //     .setData({
      //   'timeSlots': timeSlots,
      // }, merge: true);
    } catch (e) {
      print(e.toString());
    }
  }

  // LEAVE time slot
  Future leaveTimeSlot() async {
    try {
      DocumentSnapshot timeSlotSnapshot = await calendarCollection
          .document(calendarId)
          .collection(TIMESLOTS)
          .document(timeSlotId)
          .get();

      // Updates user's bookings
      DocumentSnapshot userSnapshot =
          await userCollection.document(userId).get();
      final Map<String, String> bookings =
          new Map<String, String>.from(userSnapshot.data['bookings']);
      bookings.remove(timeSlotId);
      await userCollection.document(userId).setData({
        'bookings': bookings,
      }, merge: true);
      // DocumentSnapshot followedSnapshot = await userCollection
      //     .document(userId)
      //     .collection(FOLLOWED_CALENDARS)
      //     .document(calendarId)
      //     .get();
      // final Map<String, String> timeSlots =
      //     new Map<String, String>.from(followedSnapshot.data['timeSlots']);
      // timeSlots.remove(timeSlotId);
      // await userCollection
      //     .document(userId)
      //     .collection(FOLLOWED_CALENDARS)
      //     .document(calendarId)
      //     .setData({
      //   'timeSlots': timeSlots,
      // }, merge: true);

      // Removes user to time slot's occupants
      Map<String, String> occupants =
          new Map<String, String>.from(timeSlotSnapshot.data['occupants']);
      occupants.remove(userId);
      await calendarCollection
          .document(calendarId)
          .collection(TIMESLOTS)
          .document(timeSlotId)
          .setData({
        'occupants': occupants,
      }, merge: true);
    } catch (e) {
      print(e.toString());
    }
  }

  // KICK from time slot
  Future kickFromTimeSlot(String kickedUserId) async {
    try {
      DocumentSnapshot timeSlotSnapshot = await calendarCollection
          .document(calendarId)
          .collection(TIMESLOTS)
          .document(timeSlotId)
          .get();

      // Updates user's bookings
      DocumentSnapshot userSnapshot =
          await userCollection.document(kickedUserId).get();
      final Map<String, String> bookings =
          new Map<String, String>.from(userSnapshot.data['bookings']);
      bookings.remove(timeSlotId);
      await userCollection.document(kickedUserId).setData({
        'bookings': bookings,
      }, merge: true);
      // DocumentSnapshot followedSnapshot = await userCollection
      //     .document(kickedUserId)
      //     .collection(FOLLOWED_CALENDARS)
      //     .document(calendarId)
      //     .get();
      // final Map<String, String> timeSlots =
      //     new Map<String, String>.from(followedSnapshot.data['timeSlots']);
      // timeSlots.remove(timeSlotId);
      // await userCollection
      //     .document(kickedUserId)
      //     .collection(FOLLOWED_CALENDARS)
      //     .document(calendarId)
      //     .setData({
      //   'timeSlots': timeSlots,
      // }, merge: true);

      // Removes user to time slot's occupants
      Map<String, String> occupants =
          new Map<String, String>.from(timeSlotSnapshot.data['occupants']);
      occupants.remove(kickedUserId);
      await calendarCollection
          .document(calendarId)
          .collection(TIMESLOTS)
          .document(timeSlotId)
          .setData({
        'occupants': occupants,
      }, merge: true);
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
