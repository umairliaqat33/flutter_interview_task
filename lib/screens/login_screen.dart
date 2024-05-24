// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interview_task/controller/firestore_controller.dart';
import 'package:flutter_interview_task/main.dart';
import 'package:flutter_interview_task/models/user_model.dart';
import 'package:flutter_interview_task/repository/auth_repository.dart';
import 'package:flutter_interview_task/screens/registration_screen.dart';
import 'package:flutter_interview_task/services/notification_service.dart';
import 'package:flutter_interview_task/utils/exceptions.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    label: Text("Email"),
                    hintText: "johndoe@email.com",
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Email required";
                    } else if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                        .hasMatch(value)) {
                      return "Enter a valid email";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    label: Text("Password"),
                    hintText: "Your password min 8 charactors",
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password required";
                    } else if (value.length < 8) {
                      return "Minimum 8 character required in password";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Don't have an account? "),
                    TextButton(
                      style: const ButtonStyle(
                          splashFactory: NoSplash.splashFactory),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign up",
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                _showSpinner
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Material(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10.0),
                        elevation: 5.0,
                        child: MaterialButton(
                          onPressed: () => login(),
                          // minWidth: SizeConfig.width20(context) * 10,
                          height: 30,
                          child: const Text(
                            "Sign in",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    setState(() {
      _showSpinner = true;
    });
    try {
      if (_formKey.currentState!.validate()) {
        AuthRepository authRepository = AuthRepository();
        NotificationService notificationService = NotificationService();
        FirestoreController firestoreController = FirestoreController();
        UserCredential? userCredential = await authRepository.signin(
            email: _emailController.text, password: _passwordController.text);
        if (userCredential.user != null) {
          String? fcm = await notificationService.getToken();
          UserModel? userModel = await firestoreController.getUserModel();
          if (userModel != null) {
            firestoreController.updateUser(
              UserModel(
                email: _emailController.text,
                name: userModel.name,
                uid: userCredential.user!.uid,
                fcm: fcm!,
              ),
            );
          } else {
            firestoreController.uploadUser(
              UserModel(
                email: _emailController.text,
                name: "Some name",
                uid: userCredential.user!.uid,
                fcm: fcm!,
              ),
            );
          }
          Fluttertoast.showToast(msg: "Sign in successfull");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MyHomePage(),
            ),
            (route) => false,
          );
        }
      }
    } on IncorrectPasswordOrUserNotFound catch (e) {
      Fluttertoast.showToast(msg: e.message);
      log(e.message);
    } on NoInternetException catch (e) {
      Fluttertoast.showToast(msg: e.message);
      log(e.message);
    } on UnknownException catch (e) {
      Fluttertoast.showToast(msg: e.message);
      log(e.message);
    }
    setState(() {
      _showSpinner = false;
    });
  }
}
