import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_interview_task/utils/exceptions.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<UserCredential> signin({
    required String email,
    required String password,
  }) async {
    UserCredential? userCredential;
    try {
      userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' ||
          e.code == 'user-not-found' ||
          e.code == 'invalid-credential') {
        log(e.message.toString());
        throw IncorrectPasswordOrUserNotFound("Email or password is incorrect");
      } else if (e.code == 'network-request-failed') {
        throw SocketException("${e.code}${e.message}");
      } else {
        throw UnknownException('Something went wrong ${e.code} ${e.message}');
      }
    }
    return userCredential;
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    UserCredential? userCredential;
    try {
      userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw EmailAlreadyExistException('Email already in use');
      } else {
        throw UnknownException('Something went wrong${e.code} ${e.message}');
      }
    }
    return userCredential;
  }
}
