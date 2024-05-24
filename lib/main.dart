import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interview_task/controller/firestore_controller.dart';
import 'package:flutter_interview_task/firebase_options.dart';
import 'package:flutter_interview_task/models/user_model.dart';
import 'package:flutter_interview_task/screens/login_screen.dart';
import 'package:flutter_interview_task/services/notification_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final NotificationService notificationService = NotificationService();
  await notificationService.initLocalNotification();
  await FirebaseMessaging.instance.getInitialMessage();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isUserLoggedIn ? const MyHomePage() : const LoginScreen(),
    );
  }

  void _checkIfUserLoggedIn() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isUserLoggedIn = true;
    } else {
      isUserLoggedIn = false;
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final NotificationService notificationService = NotificationService();
  String userName = '';
  @override
  void initState() {
    super.initState();
    notificationService.firebaseNotification(context);
    getUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Fluttertoast.showToast(msg: "Signout successfull");
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              userName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () => sendNotification(),
              child: const Text("Send me a notification"),
            ),
          ],
        ),
      ),
    );
  }

  void sendNotification() {
    notificationService.sendNotification(
      body: "You received a notification",
    );
  }

  Future<void> getUserName() async {
    FirestoreController firestoreController = FirestoreController();
    UserModel? userModel = await firestoreController.getUserModel();
    if (userModel != null) {
      userName = userModel.name;
      setState(() {});
    }
  }
}
