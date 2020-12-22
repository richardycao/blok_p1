import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create User object based on Firebase user
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null
        ? User(
            userId: user.uid, displayName: user.displayName, email: user.email)
        : null;
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  // sign in anon (quick start - join calendar)
  Future<User> signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;

      // create a new document for the user with the userId
      await DatabaseService(userId: user.uid).updateUserData(null);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // update user's display name
  // Future updateDisplayName(String name, FirebaseUser currentUser) async {
  //   var userUpdateInfo = UserUpdateInfo();
  //   userUpdateInfo.displayName = name;
  //   await currentUser.updateProfile(userUpdateInfo);
  //   await currentUser.reload();
  // }

  // convert anon to email and password
  Future convertUserWithEmailAndPassword(
      String email, String password, String name) async {
    final user = await _auth.currentUser();

    final credential =
        EmailAuthProvider.getCredential(email: email, password: password);
    await user.linkWithCredential(credential);

    // create a new document for the user with the userId
    await DatabaseService(userId: user.uid).updateUserData(email);
  }

  // register with email and password (quick start - create calendar)
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          // may be different for anon -> email
          email: email,
          password: password);
      FirebaseUser user = result.user;

      // create a new document for the user with the userId
      await DatabaseService(userId: user.uid).updateUserData(email);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email and password (quick start - returning user)
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future<void> signOut() async {
    try {
      _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
