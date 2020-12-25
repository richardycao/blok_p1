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
  Stream<FirebaseUser> get user {
    return _auth.onAuthStateChanged; //.map(_userFromFirebaseUser);
  }

  // sign in anon (quick start - join calendar)
  Future<User> signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      updateDisplayName("Guest", user);

      // create a new document for the user with the userId
      await DatabaseService(userId: user.uid).createUser(displayName: "Guest");
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // update user's display name
  Future updateDisplayName(String name, FirebaseUser user) async {
    var updateInfo = UserUpdateInfo();
    updateInfo.displayName = name;
    await user.updateProfile(updateInfo);
    await user.reload();
  }

  // convert anon to email and password
  Future convertUserWithEmailAndPassword(String email, String password) async {
    try {
      final user = await _auth.currentUser();

      final credential =
          EmailAuthProvider.getCredential(email: email, password: password);
      AuthResult result = await user.linkWithCredential(credential);
      FirebaseUser resultUser = result.user;

      // update user info in firestore
      await DatabaseService(userId: user.uid).updateUserData(email: email);
      return _userFromFirebaseUser(resultUser);
    } catch (e) {
      print(e);
      return null;
    }
  }

  // register with email and password (quick start - create calendar)
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      // creates a user in firebase auth
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      updateDisplayName("Guest", user);

      // creates user in firestore
      await DatabaseService(userId: user.uid).createUser(email: email);
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
