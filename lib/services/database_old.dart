import 'package:blok_p1/constants/testing_constants.dart';
import 'package:blok_p1/models/calendar.dart';
import 'package:blok_p1/models/request.dart';
import 'package:blok_p1/models/time_slot.dart';
import 'package:blok_p1/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService_old {
  static const String USERS = 'users';
  static const String CALENDARS = 'calendars';
  static const String TIMESLOTS = 'timeSlots';
  static const String REQUESTS = 'requests';

  String userId;
  String calendarId;
  String timeSlotId;
  String requestId;
  DatabaseService_old(
      {this.userId, this.calendarId, this.timeSlotId, this.requestId});

  final CollectionReference userCollection =
      Firestore.instance.collection(USERS);
  final CollectionReference calendarCollection =
      Firestore.instance.collection(CALENDARS);
  final CollectionReference requestCollection =
      Firestore.instance.collection(REQUESTS);

  /////////////////////////////////////////////////////////////////////
  /// STREAMS
  /////////////////////////////////////////////////////////////////////

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

  Stream<Request> streamRequest() {
    try {
      return requestCollection
          .document(requestId)
          .snapshots()
          .map((snapshot) => Request.fromSnapshot(snapshot));
    } catch (e) {
      print(e);
      return null;
    }
  }

  /////////////////////////////////////////////////////////////////////
  /// USER
  /////////////////////////////////////////////////////////////////////

  // CREATE user
  // input: userId
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
      'incomingRequests': {},
      'outgoingRequests': {},
    });
  }

  // UPDATE user data
  // input: userId
  Future updateUserData(
      {String displayName, String email, bool serverEnabled}) async {
    await userCollection.document(userId).setData({
      if (displayName != null) 'displayName': displayName,
      if (email != null) 'email': email,
      if (serverEnabled != null) 'serverEnabled': serverEnabled,
    }, merge: true);
  }

  /////////////////////////////////////////////////////////////////////
  /// CALENDAR
  /////////////////////////////////////////////////////////////////////

  // CREATE calendar
  // input: userId
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
        'requests': {},
        'requiresJoinApproval': true,
        'timeSlotRequiresOwnerApproval': true,
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
          'requests': {},
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

  // JOIN calendar
  // input: userId, calendarId
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

  // ADD user to calendar
  // input: none
  Future addFollowerToCalendar(
      String addedUserId, String addedCalendarId) async {
    try {
      DocumentSnapshot calendarSnapshot =
          await calendarCollection.document(addedCalendarId).get();

      // Adds user to calendar's list of followers
      await calendarCollection.document(addedCalendarId).updateData({
        "followers.$addedUserId": temp_name,
      });

      // Updates user's followed calendars
      await userCollection.document(addedUserId).updateData({
        "followedCalendars.$addedCalendarId":
            calendarSnapshot.data['name'] as String,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // LEAVE calendar or KICK from calendar
  // input: userId, calendarId
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
  // input: calendarId
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

  /////////////////////////////////////////////////////////////////////
  /// TIME SLOT
  /////////////////////////////////////////////////////////////////////

  // JOIN time slot
  // input: userId, calendarId, timeSlotId
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

  // ADD occupant to time slot
  // input: userId, calendarId, timeSlotId
  Future addOccupantToTimeSlot(String addedUserId, String addedCalendarId,
      String addedTimeSlotId, String name) async {
    try {
      // Adds user to time slot's occupants
      await calendarCollection
          .document(addedCalendarId)
          .collection(TIMESLOTS)
          .document(addedTimeSlotId)
          .updateData({
        "occupants.$addedUserId": name,
      });

      // Updates user's bookings
      await userCollection.document(addedUserId).updateData({
        "bookings.$addedTimeSlotId": addedCalendarId,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // LEAVE time slot
  // input: userId, calendarId, timeSlotId
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
  // input: none
  Future kickFromTimeSlot(String kickedUserId, String kickedCalendarId,
      String kickedTimeSlotId) async {
    try {
      // Updates user's bookings
      Map<String, Object> deleteTimeSlotId = {};
      deleteTimeSlotId["bookings.$kickedTimeSlotId"] = FieldValue.delete();
      await userCollection.document(kickedUserId).updateData(deleteTimeSlotId);

      // Removes user to time slot's occupants
      Map<String, Object> deleteUserId = {};
      deleteUserId["occupants.$kickedUserId"] = FieldValue.delete();
      await calendarCollection
          .document(kickedCalendarId)
          .collection(TIMESLOTS)
          .document(kickedTimeSlotId)
          .updateData(deleteUserId);
    } catch (e) {
      print(e.toString());
    }
  }

  // UPDATE time slot data
  // input: calendarId, timeSlotId
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
      occupants.forEach((kickedUserId, kickedName) async {
        await kickFromTimeSlot(kickedUserId, calendarId, timeSlotId);
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

  /////////////////////////////////////////////////////////////////////
  /// REQUEST
  /////////////////////////////////////////////////////////////////////

  // CREATE request to join calendar
  // input: userId, calendarId
  Future<bool> createRequestJoinCalendar(String name,
      {String message = ""}) async {
    try {
      DocumentSnapshot calendarSnapshot =
          await calendarCollection.document(calendarId).get();

      // if the user is already a follower or has a pending request, do nothing.
      if (Map<String, String>.from(calendarSnapshot.data['followers'])
              .containsKey(userId) ||
          Map<String, String>.from(calendarSnapshot.data['requests'])
              .containsValue(userId)) {
        return null;
      }

      if (calendarSnapshot.data['requiresJoinApproval'] as bool == false) {
        joinCalendar();
        return true;
      }

      DateTime now = DateTime.now();

      // creates a request and gets requestId
      DocumentReference docRef = await requestCollection.add({
        'type': "calendar",
        'itemId': calendarId,
        'requesterId': userId,
        'requesterName': name,
        'ownerApprovers': calendarSnapshot.data['owners'],
        'otherApprovers': {},
        'hasOwnerApproval': false,
        'hasOtherApproval': true,
        'responses': {},
        'message': message,
        'createDate': now,
      });
      String newRequestId = docRef.documentID;

      // update outgoing requests for requester
      await userCollection.document(userId).updateData({
        "outgoingRequests.$newRequestId": calendarId,
      });

      // update incoming requests for approvers
      Map<String, String>.from(calendarSnapshot.data['owners'])
          .forEach((approverUserId, approverName) async {
        await userCollection.document(approverUserId).updateData({
          "incomingRequests.$newRequestId": calendarId,
        });
      });

      // update requests for calendar
      await calendarCollection.document(calendarId).updateData({
        "requests.$newRequestId": userId,
      });

      return false;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // RESPOND to request to join calendar
  // Input: userId, requestId
  Future respondRequestJoinCalendar(int decision) async {
    // get the request object
    DocumentSnapshot snapshot =
        await requestCollection.document(requestId).get();
    Request request = Request.fromSnapshot(snapshot);

    // add the approver user's decision
    request.responses[userId] = decision;

    Map<String, int> ownerResponses = Map<String, int>.fromEntries(request
        .responses.entries
        .where((element) => request.ownerApprovers.containsKey(element.key)));
    // if the user is an owner, the request status will be adjusted based on their decision
    if (request.ownerApprovers.containsKey(userId)) {
      // if there is an approving owner response, then hasOwnerApproval is true
      request.hasOwnerApproval =
          ownerResponses.entries.where((element) => element.value == 1).length >
              0;
    }

    // if the request has passed, add user to calendar, then delete the request
    if (request.hasOwnerApproval) {
      await addFollowerToCalendar(request.requesterId, request.itemId);
      await deleteCalendarRequest(request);
    }
    // else if the request has certain failed, delete the request from requests, users, and calendars
    else if (request.ownerApprovers.length == ownerResponses.length) {
      // if the number of people remaining is strictly less than the number of approvals needed
      await deleteCalendarRequest(request);
    }
    // else, update the request in firestore
    else {
      await requestCollection.document(requestId).updateData({
        "responses.${request.requesterId}": decision,
      });
    }
  }

  // DELETE join calendar request
  // input: none
  Future deleteCalendarRequest(Request request) async {
    // delete outgoing request for requester user
    Map<String, Object> deleteOutgoingRequestId = {};
    deleteOutgoingRequestId["outgoingRequests.$requestId"] =
        FieldValue.delete();
    await userCollection
        .document(request.requesterId)
        .updateData(deleteOutgoingRequestId);

    Map<String, String> approvers = {};
    approvers.addAll(request.ownerApprovers);

    // delete incoming request for approver users
    approvers.forEach((approverUserId, approverName) async {
      Map<String, Object> deleteIncomingRequestId = {};
      deleteIncomingRequestId["incomingRequests.$requestId"] =
          FieldValue.delete();
      await userCollection
          .document(approverUserId)
          .updateData(deleteIncomingRequestId);
    });

    // delete request from calendar
    Map<String, Object> deleteCalendarRequestId = {};
    deleteCalendarRequestId["requests.$requestId"] = FieldValue.delete();
    await calendarCollection
        .document(request.itemId)
        .updateData(deleteCalendarRequestId);

    // delete request object
    await requestCollection.document(requestId).delete();
  }

  // CREATE request to join calendar time slot
  // input: userId, calendarId, timeSlotId
  Future<bool> createRequestJoinTimeSlot(String name,
      {String message = ""}) async {
    try {
      DocumentSnapshot userSnapshot =
          await userCollection.document(userId).get();
      DocumentSnapshot calendarSnapshot =
          await calendarCollection.document(calendarId).get();
      DocumentSnapshot timeSlotSnapshot = await calendarCollection
          .document(calendarId)
          .collection(TIMESLOTS)
          .document(timeSlotId)
          .get();

      // if the user is already an occupant or has a pending request, do nothing.
      if (Map<String, String>.from(timeSlotSnapshot.data['occupants'])
              .containsKey(userId) ||
          Map<String, String>.from(timeSlotSnapshot.data['requests'])
              .containsValue(userId)) {
        return null;
      }

      if (calendarSnapshot.data['timeSlotRequiresOwnerApproval'] as bool ==
          false) {
        joinTimeSlot(name);
        return true;
      }

      DateTime now = DateTime.now();
      Map approvers = {};
      approvers.addAll(calendarSnapshot.data['owners']);
      // If the time slot is full, add the occupants as approvers
      bool isFull = timeSlotSnapshot.data['occupants'].length >=
          timeSlotSnapshot.data['limit'];
      if (isFull) {
        approvers.addAll(timeSlotSnapshot.data['occupants']);
      } // else, only owner approval is required
      approvers = Map<String, String>.from(approvers);

      // creates a request and gets requestId
      DocumentReference docRef = await requestCollection.add({
        'type': "timeSlot",
        'itemId': timeSlotId,
        'requesterId': userId,
        'requesterName': name,
        'ownerApprovers': calendarSnapshot.data['owners'],
        'otherApprovers': timeSlotSnapshot.data['occupants'],
        'hasOwnerApproval': false,
        'hasOtherApproval': !isFull,
        'responses': {},
        'message': message,
        'createDate': now,
      });
      String newRequestId = docRef.documentID;

      // update outgoing requests for requester
      await userCollection.document(userId).updateData({
        "outgoingRequests.$newRequestId": timeSlotId,
      });

      // update incoming requests for approvers
      Map<String, String>.from(approvers)
          .forEach((approverUserId, approverName) async {
        await userCollection.document(approverUserId).updateData({
          "incomingRequests.$newRequestId": timeSlotId,
        });
      });

      // update requests for time slots
      await calendarCollection
          .document(calendarId)
          .collection(TIMESLOTS)
          .document(timeSlotId)
          .updateData({
        "requests.$newRequestId": userId,
      });

      return false;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // RESPOND to request to join time slot
  // Input: userId, requestId, ?
  Future respondRequestJoinTimeSlot(int decision) async {
    // get the request object
    DocumentSnapshot snapshot =
        await requestCollection.document(requestId).get();
    Request request = Request.fromSnapshot(snapshot);
    String timeSlotCalendarId = request.itemId.split("-")[0];

    // add the approver user's decision
    request.responses[userId] = decision;
    Map<String, int> ownerResponses = Map<String, int>.fromEntries(request
        .responses.entries
        .where((element) => request.ownerApprovers.containsKey(element.key)));
    Map<String, int> otherResponses = Map<String, int>.fromEntries(request
        .responses.entries
        .where((element) => request.otherApprovers.containsKey(element.key)));

    // if the user is an owner, update
    bool isOwner = request.ownerApprovers.containsKey(userId);
    bool isOther = request.otherApprovers.containsKey(userId);
    if (isOwner) {
      print('is owner');
      request.hasOwnerApproval = decision == 1
          ? true
          : ownerResponses.entries
                  .where((element) => element.value == 1)
                  .length >
              0;
    }
    // if the user is an other, update
    if (isOther) {
      print('is other');
      request.hasOtherApproval = decision == 1
          ? true
          : otherResponses.entries
                  .where((element) => element.value == 1)
                  .length >
              0;
    }

    print('1');
    // if the request has passed, add user to calendar, then delete the request
    if (request.hasOwnerApproval && request.hasOtherApproval) {
      print('passed');
      request.otherApprovers.forEach((kickedUserId, kickedName) async {
        await kickFromTimeSlot(
            kickedUserId, timeSlotCalendarId, request.itemId);
      });
      await addOccupantToTimeSlot(request.requesterId, timeSlotCalendarId,
          request.itemId, request.requesterName);
      await deleteTimeSlotRequest(request);
    }
    // else if the request has for certain failed,
    // then delete the request from requests, users, and calendars
    else if ((ownerResponses.length == request.ownerApprovers.length &&
            !request.hasOwnerApproval) ||
        (otherResponses.length == request.otherApprovers.length &&
            !request.hasOwnerApproval)) {
      print('failed');
      await deleteTimeSlotRequest(request);
    }
    // else, update the request in firestore
    else {
      print('update');
      await requestCollection.document(requestId).updateData({
        if (isOwner) "hasOwnerApproval": request.hasOwnerApproval,
        if (isOther) "hasOtherApproval": request.hasOtherApproval,
        "responses.${request.requesterId}": decision,
      });
    }
  }

  // DELETE join time slot request
  // input: none
  Future deleteTimeSlotRequest(Request request) async {
    String timeSlotCalendarId = request.itemId.split("-")[0];

    // delete outgoing request for requester user
    Map<String, Object> deleteOutgoingRequestId = {};
    deleteOutgoingRequestId["outgoingRequests.$requestId"] =
        FieldValue.delete();
    await userCollection
        .document(request.requesterId)
        .updateData(deleteOutgoingRequestId);

    Map<String, String> approvers = {};
    approvers.addAll(request.ownerApprovers);
    approvers.addAll(request.otherApprovers);

    // delete incoming request for approver users
    approvers.forEach((approverUserId, approverName) async {
      Map<String, Object> deleteIncomingRequestId = {};
      deleteIncomingRequestId["incomingRequests.$requestId"] =
          FieldValue.delete();
      await userCollection
          .document(approverUserId)
          .updateData(deleteIncomingRequestId);
    });

    // delete request from time slot
    Map<String, Object> deleteTimeSlotRequestId = {};
    deleteTimeSlotRequestId["requests.$requestId"] = FieldValue.delete();
    await calendarCollection
        .document(timeSlotCalendarId)
        .collection(TIMESLOTS)
        .document(request.itemId)
        .updateData(deleteTimeSlotRequestId);

    // delete request object
    await requestCollection.document(requestId).delete();
  }
}
