import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../signin.dart';
import 'coachSalary.dart';

class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({Key? key}) : super(key: key);

  @override
  State<CoachProfileScreen> createState() => CoachProfileScreenState();
}

class CoachProfileScreenState extends State<CoachProfileScreen> {
  String? uid;
  String? username;
  String? email;
  String? phone_no;
  String? address;
  String? imageUrl;
  @override
  void initState() {
    super.initState();
    _loadUserData();
    // _calculateUserLevel();// Load user data when the widget is created
  }

  Future<void> _loadUserData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      uid = currentUser.uid;
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        final data = userSnapshot.data();
        if (data != null) {
          setState(() {
            email = data['email'];
            username = data['username'];
            phone_no = data['phone_no'];
            address = data['address'];
            imageUrl = data['imageUrl'];
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(email ?? ""),

          CircleAvatar(
            radius: 80,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null ? Icon(Icons.person, size: 60) : null,
          ),
          const SizedBox(height: 20),
          Text(
            '$username',
            style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            'Email: ${email ?? "N/A"}',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),
          Text(
            'Phone number: ${phone_no ?? "N/A"}',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),
          Text(
            'Address: ${address ?? "N/A"}',
            style: TextStyle(fontSize: 15),
          ),
          ElevatedButton(
            child: Text("Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff9b1616),
            ),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                print("Signed Out");
                setState(() {
                  uid = null;
                  email = null;
                  address = null;
                });
                // FirebaseAuth.instance.setPersistence(Persistence.NONE);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Signin()));
              });
            },
          ),
        ],
      ),
    );
  }
}
