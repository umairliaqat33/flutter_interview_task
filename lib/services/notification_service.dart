import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interview_task/controller/firestore_controller.dart';
import 'package:flutter_interview_task/main.dart';
import 'package:flutter_interview_task/models/user_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

void backgroundMessageHandler(NotificationResponse response) {
  log("Notification id: ${response.id}");
}

class NotificationService {
  final _localNotification = FlutterLocalNotificationsPlugin();
  Future<void> initLocalNotification() async {
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true,
    );
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const setting = InitializationSettings(
      android: android,
      iOS: iOS,
    );
    await _localNotification.initialize(setting,
        onDidReceiveBackgroundNotificationResponse: backgroundMessageHandler);
  }

  Future<void> _showNotification(RemoteMessage remoteMessage) async {
    final styleInformation = BigTextStyleInformation(
      remoteMessage.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: remoteMessage.notification!.title,
      htmlFormatTitle: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );

    final androidDetails = AndroidNotificationDetails(
      'com.example.flutter_interview_task',
      'my_channelid',
      importance: Importance.high,
      styleInformation: styleInformation,
      priority: Priority.max,
    );

    final notificationDetails = NotificationDetails(
      iOS: iosDetails,
      android: androidDetails,
    );

    await _localNotification.show(
      0,
      remoteMessage.notification!.title,
      remoteMessage.notification!.body,
      notificationDetails,
      payload: remoteMessage.data['body'],
    );
  }

  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("User granted notification permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint("User granted provisional notification permission");
    } else {
      debugPrint("User declined notification permission");
    }
  }

  Future<String?> getToken() async {
    final fCMToken = await FirebaseMessaging.instance.getToken();
    return fCMToken;
  }

  Future<void> sendNotification({
    required String body,
  }) async {
    FirestoreController firestoreController = FirestoreController();
    UserModel? userModel = await firestoreController.getUserModel();
    try {
      final repsonse = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAA1uwK3Lw:APA91bGHJ-CSKAwSfn6-rTxegFhLw2BuZvo6_vsPxMN5b20oUd15B8HgUliOE--8sX5WG3AFeUnY-_-ZX_lUM5N3VZQH8tFmlGM4-zjZMvB9TEUcz9e_sZJ9V75kl9-1_7TIGbVqoTyU',
        },
        body: jsonEncode(
          <String, dynamic>{
            "to": userModel!.fcm,
            "priority": 'high',
            "notification": <String, dynamic>{
              'body': body,
              "title": "New Message !"
            },
            'data': <String, String>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
            }
          },
        ),
      );
      log(repsonse.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  void firebaseNotification(context) async {
    initLocalNotification();
    //background notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MyHomePage(),
        ),
        (route) => false,
      );
    });
    //foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showNotification(message);
    });
  }
}
