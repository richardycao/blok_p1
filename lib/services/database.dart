import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String userId;
  DatabaseService({this.userId});

  // collection reference
  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  // call this when a new user signs up (including converting (?))
  Future updateUserData(String email, {String displayName = "Guest"}) async {
    return await userCollection.document(userId).setData({
      'displayName': displayName,
      'email': email,
    });
  }
}
