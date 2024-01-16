import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CoachSelectionScreen extends StatefulWidget {
  @override
  _CoachSelectionScreenState createState() => _CoachSelectionScreenState();
}

class _CoachSelectionScreenState extends State<CoachSelectionScreen> {
  String? selectedCoach;
  bool coachSelected = false;
  List<String> coachNames = [];

  @override
  void initState() {
    super.initState();
    fetchCoachData();
  }

  Future<void> fetchCoachData() async {
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: "coach")
        .get();

    setState(() {
      coachNames = usersSnapshot.docs
          .map((doc) => doc['username'] as String)
          .toList();
    });

    print('Available Coach Names: $coachNames');

    String? currentUserUID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUID != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUID)
          .get()
          .then((userDoc) {
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          if (userData.containsKey('coachName')) {
            print('CoachName already exists for the current user.');

            // If 'coachName' field exists, set the selectedCoach and coachSelected states
            setState(() {
              selectedCoach = userData['coachName'] as String?;
              coachSelected = true;
            });
          }
        }
      }).catchError((e) {
        print('Error fetching Firestore document: $e');
      });
    }
  }

  void _handleRadioValueChanged(String? value) {
    setState(() {
      selectedCoach = value;
    });
  }

  void _selectCoach() async {
    if (selectedCoach != null) {
      String? currentUserUID = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserUID != null) {
        try {
          // Update the current user's document in Firestore with the selected coach's name
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserUID)
              .update({'coachName': selectedCoach});

          // Fetch the coach's document based on the selected coach's username
          QuerySnapshot coachSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: selectedCoach)
              .get();

          if (coachSnapshot.docs.isNotEmpty) {
            DocumentSnapshot coachDoc = coachSnapshot.docs.first;
            String coachUID = coachDoc.id;
            await FirebaseFirestore.instance
                .collection('users')
                .doc(coachUID)
                .update({
              'trainedUsers': FieldValue.arrayUnion([currentUserUID])
            });
          }
          print(
              'Selected Coach $selectedCoach has been stored for the current user and added to coach\'s trained users.');
          setState(() {
            coachSelected = true;
          });
        } catch (e) {
          print('Error updating Firestore document: $e');
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please select a coach before proceeding.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coach Selection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Coach Selection System',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            if (coachSelected && selectedCoach != null)
              Text(
                'Selected Coach: $selectedCoach',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            if (!coachSelected)
              ...coachNames.map(
                    (name) => RadioListTile<String>(
                      activeColor:Colors.white70,
                  title: Text(name),
                      value: name,
                      groupValue: selectedCoach,
                      onChanged: _handleRadioValueChanged,
                ),
              ).toList(),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff9b1616),
              ),
              onPressed: coachSelected ? null : _selectCoach,
              child: Text('Select Coach'),
            ),
          ],
        ),
      ),
    );
  }
}
