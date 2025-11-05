
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e, s) {
      developer.log(
        'Failed to sign in with email and password',
        name: 'com.example.alttask.auth',
        error: e,
        stackTrace: s,
      );
      return null;
    } catch (e, s) {
      developer.log(
        'Unexpected error during email sign-in',
        name: 'com.example.alttask.auth',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.sendEmailVerification();
      return result.user;
    } on FirebaseAuthException catch (e, s) {
      developer.log(
        'Failed to register with email and password',
        name: 'com.example.alttask.auth',
        error: e,
        stackTrace: s,
      );
      return null;
    } catch (e, s) {
      developer.log(
        'Unexpected error during email registration',
        name: 'com.example.alttask.auth',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, s) {
      developer.log(
        'Failed to send password reset email',
        name: 'com.example.alttask.auth',
        error: e,
        stackTrace: s,
      );
    } catch (e, s) {
      developer.log(
        'Unexpected error during password reset email',
        name: 'com.example.alttask.auth',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e, s) {
      developer.log(
        'Failed to sign out',
        name: 'com.example.alttask.auth',
        error: e,
        stackTrace: s,
      );
    } catch (e, s) {
      developer.log(
        'Unexpected error during sign out',
        name: 'com.example.alttask.auth',
        error: e,
        stackTrace: s,
      );
    }
  }
}
