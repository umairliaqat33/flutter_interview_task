import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interview_task/screens/home_screen.dart';
import 'package:flutter_interview_task/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _createSplash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(
          "https://www.pushengage.com/wp-content/uploads/2022/10/How-to-Add-a-Push-Notification-Icon.png",
          width: double.infinity,
          height: 200,
        ),
      ),
    );
  }

  void _createSplash() {
    Future.delayed(
      const Duration(seconds: 3),
      () {
        log("I am in splash duration");
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          log('No user logged in');
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                user == null ? const LoginScreen() : const MyHomePage(),
          ),
          (route) => false,
        );
      },
    );
  }
}
