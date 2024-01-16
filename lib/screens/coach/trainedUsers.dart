import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../member/profile_screen.dart';
import '../recpetionist/viewDetails.dart';
import 'coachCheckProgress.dart';

class TrainingPage extends StatefulWidget {
  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isChecked = false;
  String currentDate = DateTime.now().toString().split(' ')[0];
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Map<String, String> usernames = {}; // Map to store user IDs and usernames

  @override
  void initState() {
    super.initState();
    _loadUsernames();
  }


  Future<void> _loadUsernames() async {
    QuerySnapshot usersSnapshot = await firestore.collection('users').get();
    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      String username = userDoc['username'];
      String userUID = userDoc.id;
      usernames[userUID] = username;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int trainedUsersTodayCount = 0;
    return Scaffold(
      body:StreamBuilder<DocumentSnapshot>(
        stream: firestore.collection('users').doc(uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData || usernames.isEmpty) {
            return CircularProgressIndicator();
          }

          List<dynamic> trainedUsers = userSnapshot.data!['trainedUsers'] ?? [];

          return StreamBuilder<DocumentSnapshot>(
            stream: firestore.collection('users').doc(uid).collection('attendance').doc(currentDate).snapshots(),
            builder: (context, attendanceSnapshot) {
              if (!attendanceSnapshot.hasData) {
                return CircularProgressIndicator();
              }
              Map<String, dynamic>? attendanceData = attendanceSnapshot.data?.data() as Map<String, dynamic>?;
              List<dynamic>? trainedUsersToday = attendanceData?['trainedUsersToday'];              // print('trainedUsersTOday: $trainedUsersToday');
              return ListView.builder(
                itemCount: trainedUsers.length,
                itemBuilder: (context, index) {
                  String userUID = trainedUsers[index];
                  String username = usernames[userUID] ?? 'Unknown User';
                  bool isChecked = trainedUsersToday?.contains(userUID) ?? false ;
                  trainedUsersTodayCount = trainedUsersToday?.length ?? 0;
                  return ListTile(
                    // title: Row(
                    //   children: [
                    //     Text(username),
                    //     SizedBox(width: 140),
                    //     Checkbox(
                    //       checkColor: Colors.black,
                    //       activeColor: Colors.white70,
                    //       value: isChecked,
                    //       onChanged: (bool? value) {
                    //         setState(() {
                    //           if (value == true) {
                    //             markUserAsTrained(userUID, trainedUsersTodayCount);
                    //
                    //           } else {
                    //             removeUserFromTrained(userUID, trainedUsersTodayCount);
                    //           }
                    //         });
                    //       },
                    //     ),
                    //     // ElevatedButton(
                    //     //   style: ElevatedButton.styleFrom(
                    //     //     backgroundColor: Color(0xff9b1616),
                    //     //   ),
                    //     //   child: Text("View Progress"),
                    //     //   onPressed: () {
                    //     //
                    //     //     Navigator.push(
                    //     //         context, MaterialPageRoute(builder: (context) => CoachCheckProg()));
                    //     //   },
                    //     // ),
                    //   ],
                    // ),
                    title: Table(
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.only(top:12.0,left: 4.0),
                                child: Text(username),
                              ),
                            ),
                            TableCell(
                                child: Checkbox(
                                  checkColor: Colors.black,
                                  activeColor: Colors.white70,
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        markUserAsTrained(userUID, trainedUsersTodayCount);
                                      } else {
                                        removeUserFromTrained(userUID, trainedUsersTodayCount);
                                      }
                                    });
                                  },
                                ),
                              ),
                            TableCell(
                              child: Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff9b1616),
                                  ),
                                  child: Text("Progress", style:TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => CoachCheckProg(uid: userUID, username: username)),
                                    );
                                  },
                                 ),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff9b1616),
                                  ),
                                  child: Text("Details", style:TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ViewDetails(uid: userUID)),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  );
                },
              );
            },
          );
        },
      )
    );
  }

  void markUserAsTrained(String userUID, int trainedUsersTodayCount) async {

    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('attendance')
          .doc(currentDate);

      await userDocRef.update({
        'trainedUsersToday': FieldValue.arrayUnion([userUID]),
        'trainedUsersCount':trainedUsersTodayCount+1,
      });
      print('User marked as trained: $userUID');

    } catch (e) {
      print('Error marking user as trained: $e');
    }
  }

  void removeUserFromTrained(String userUID, int trainedUsersTodayCount) async {
    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('attendance')
          .doc(currentDate);

      await userDocRef.update({
        'trainedUsersToday': FieldValue.arrayRemove([userUID]),
        'trainedUsersCount':trainedUsersTodayCount-1,
      });

      print('User removed from trained: $userUID');
    } catch (e) {
      print('Error removing user from trained: $e');
    }
  }

}
