import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sample_app/screens/signin.dart';

import '../services/authServices.dart';

import '../utils/constants.dart';
import 'member/UserNav.dart';
import 'member/qr_scan.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({Key? key}) : super(key: key);

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String? email;
  String? username;
  String? role;
  String? uid;
  String _data = "";

  Future<bool> pushNotificationsSpecificDevice({
    required String token,
    required String title,
    required String body,
  }) async {
    String dataNotifications = '{ "to" : "$token",'
        ' "notification" : {'
        ' "title":"$title",'
        '"body":"$body"'
        ' }'
        ' }';

    await http.post(
      Uri.parse(Constants.BASE_URL),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key= ${Constants.KEY_SERVER}',
      },
      body: dataNotifications,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey globalKey = GlobalKey();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    uid = user?.uid;
    // email = user?.email;

    if (uid != null) {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      userDocRef.get().then((DocumentSnapshot documentSnapshot) {
        if (mounted) {
          Map<String, dynamic>? userData =
              documentSnapshot.data() as Map<String, dynamic>?;
          setState(() {
            email = userData!['email'];
            username = userData['username'];
            role = userData['role'];
          });
        }
      });
    }
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(email ?? ""),
        backgroundColor: Colors.black,
      ),

      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(username ?? ""),
          Text('User role: $role'),
          SizedBox(
            height: 20,
          ),
          //QR generator
          Container(
            color: Colors.white,
            child: RepaintBoundary(
              key: globalKey,
              child: QrImage(
                data: uid ?? "", //text for qR generator
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Text('Data: $uid'),

          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.black,
          //   ),
          //   onPressed: () => pushNotificationsSpecificDevice(
          //     title: "JK payments",
          //     body: "$username",
          //     token:
          //         "et35iqVHSQGmM7En5kqDGt:APA91bGksKFt_mHl3r0vtGJgQiAkII7dWl_BHzAsxMj66zDMm6MhTibxuIUTjK8MGtjy-ZmWmKh7A5SwcOPPWrRYDdSbuQjEshdGnPj-HSF4sZ9v83hxqSS5lCZHyaQ2Rb4d01mLMJH6",
          //   ),
          //   child: Text("notify"),
          // ),
        ],
      )),
    );
  }
}
