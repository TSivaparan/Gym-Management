import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sample_app/screens/signin.dart';

import '../utils/sharedPrefencesUtil.dart';
import 'coach/coachNav.dart';
import 'loadingScreen.dart';
import 'member/UserNav.dart';
import 'recpetionist/recNavigation.dart';

class Initial extends StatefulWidget {
  const Initial({Key? key}) : super(key: key);

  @override
  State<Initial> createState() => _InitialState();
}

class _InitialState extends State<Initial> {
  String? uid;
  String? role;
  String? expirationStatus;

  @override
  void initState() {
    _loadUserData();
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        "OK",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Initial()));
        FirebaseAuth.instance.signOut();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("JK Fitness"),
      content: Text("Your membership has been expired."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _loadUserData() async {
    uid = await SharedPreferencesUtil.getUser() ?? '';
    try {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      DocumentSnapshot userSnapshot = await userDocRef.get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;
        setState(() {
          role = userData!['role'];
          if (role == 'user') {
            expirationStatus = userData!['expirationStatus'];
          }
        });
      } else {
        uid = null;
        role = null;
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget initialScreen;

    if (role == 'user') {
      if (expirationStatus == 'Active') {
        initialScreen = Home();
      } else {
        initialScreen = Signin();
      }
    } else if (role == 'coach') {
      initialScreen = CoachScreen();
    } else if (role == 'receptionist') {
      initialScreen = ReceptionistScreen();
    } else {
      initialScreen = LoadingScreen();
    }

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: initialScreen,
    );
  }
}
