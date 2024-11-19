import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;  // Returns the User object
    } on FirebaseAuthException catch (e) {
      // Handle different Firebase Auth errors
      if (e.code == 'email-already-in-use') {
        throw 'This email is already registered. Please use a different email.';
      } else if (e.code == 'weak-password') {
        throw 'The password is too weak. Please use a stronger password.';
      } else if (e.code == 'invalid-email') {
        throw 'The email address is not valid. Please enter a valid email.';
      } else {
        throw 'An unknown error occurred: ${e.message}';
      }
    } catch (e) {
      // Handle other types of errors
      throw 'An error occurred: $e';
    }
  }

  static Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;  // Returns the User object
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        throw 'Incorrect password.';
      } else {
        throw 'An unknown error occurred: ${e.message}';
      }
    } catch (e) {
      throw 'An error occurred: $e';
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
