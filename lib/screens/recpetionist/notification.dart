import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/local_notifications.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String notifi = "Waiting for notification";

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googlepis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAlfpsywA:APA91bFNOpXZJWuvSAYECAL_pfwjQH6C-QvUh7VMFqoFwNJge-7yya6NVHPZqyXmMEkxP-LF170Huw3MeXaM1D_RyPSLh1N9pXaebZbWKCfxiF62i1lIxIK_hnNcWlqV6QK_5RXASYsq',
        },
        body: jsonEncode(<String, dynamic>{
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'Flutter_NOTIFICATION_CLICK',
            'status': 'done',
            'body': body,
            'title': title,
          },
          "notification": <String, dynamic>{
            "title": title,
            "body": body,
            "android_channel_id": "Sigin-sample"
          },
          "to": token,
        }),
      );
    } catch (e) {
      if (kDebugMode) {
        print("error push notification");
      }
    }
  }

  @override
  void initState() {
    super.initState();

    LocalNotificationService.initilize();
    FirebaseMessaging.instance.getInitialMessage().then((event) {
      if (event != null) {
        setState(() {
          notifi =
              "${event.notification!.title} ${event.notification!.body} I am coming from terminated state";
        });
      }
    });

    FirebaseMessaging.onMessage.listen((event) {
      LocalNotificationService.showNotificationOnForeground(event);
      setState(() {
        notifi =
            "${event.notification!.title} ${event.notification!.body} I am coming from foreground";
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      setState(() {
        notifi =
            "${event.notification!.title} ${event.notification!.body} I am coming from background";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(notifi),
      ),
    );
  }
}
