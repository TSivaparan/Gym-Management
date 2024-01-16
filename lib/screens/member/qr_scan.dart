import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import '../../utils/sharedPrefencesUtil.dart';
import '../recpetionist/viewDetails.dart';

class QRScan extends StatefulWidget {
  const QRScan({super.key});

  @override
  State<QRScan> createState() => _QRScanState();
}

class CoachInfo {
  final String name;
  final String imagePath;

  CoachInfo(this.name, this.imagePath);
}


class _QRScanState extends State<QRScan> {
  String role = "";
  int? userLevel;
  String? username;
  String? token;
  bool? hasToPay;
  String? lockerName;
  String? acceptedChallenge;
  String currentDate = DateTime.now().toString().split(' ')[0];
  String currentTime =
  DateTime.now().toLocal().toString().split(' ')[1].substring(0, 5);
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  QRViewController? controller;
  String result = "";
  bool hasToRemind = false;
  Map<String, int> extractTimeComponents(String timeString) {
    List<String> timeParts = timeString.split(':');

    return {
      'hour': int.parse(timeParts[0]),
      'minute': int.parse(timeParts[1]),
    };
  }

  Future<int> isChallengeAccepted() async {
    int remainingDays = 0;
    print('sample print');
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(result)
          .get();

      acceptedChallenge = userDoc.data()!['challengeName'];
      print('acceptedChallenge $acceptedChallenge');

      QuerySnapshot<Map<String, dynamic>> challengeSnapshot =
      await FirebaseFirestore.instance
          .collection('challenges')
          .where('challengeName', isEqualTo: acceptedChallenge)
          .get();

      if (challengeSnapshot.docs.isNotEmpty && acceptedChallenge != null) {
        Map<String, dynamic> data = challengeSnapshot.docs[0].data();

        DateTime endingDate = DateTime.parse(userDoc.data()!['endDate']);
        DateTime today = DateTime.parse(currentDate);
        Duration duration = endingDate.difference(today);
        remainingDays = duration.inDays;

        print('Remaining: $remainingDays');
        return remainingDays;
      } else {
        print('No documents found matching the query.');
      }

      print('Payment $hasToRemind');
      print('Payment $currentDate');

      return remainingDays;
    } catch (e) {
      print('Error checking subscription status: $e');
      // Handle the error as needed
      return remainingDays;
    }
  }

  void assignLockerToCurrentUser() async {
    // Initialize Firebase if you haven't already
    await Firebase.initializeApp();

    // Reference to your Firebase Realtime Database
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

    // Query the database to find available lockers
    DatabaseEvent event = await databaseReference
        .child('lockers')
        .orderByChild('availability')
        .equalTo('yes')
        .once();

    // Check if the event contains any data
    if (event.snapshot.value != null) {
      // Safely cast the Object? to Map<dynamic, dynamic>
      Map<dynamic, dynamic> lockers = event.snapshot.value as Map<dynamic, dynamic>;

      // Convert the Map to a List of locker keys and cast them to String
      List<String> availableLockerKeys = lockers.keys.cast<String>().toList();

      // Select a random locker from the available ones
      Random random = Random();
      int randomIndex = random.nextInt(availableLockerKeys.length);
      String randomLockerKey = availableLockerKeys[randomIndex];

      // Get the reference to the selected locker
      DatabaseReference selectedLockerRef =
      databaseReference.child('lockers').child(randomLockerKey);

      // Assign the locker to the current user (replace 'currentUser' with the actual user identifier)
       // Replace with your user identifier
      await selectedLockerRef.update({'user': result, 'availability': 'no'});

      print('Assigned locker $randomLockerKey to user $result');
    } else {
      print('No available lockers found.');
    }
  }

  void releaseLockerIfUserIsOut() async {
    // Initialize Firebase if you haven't already
    await Firebase.initializeApp();
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

    DatabaseReference reference =
    FirebaseDatabase.instance.reference().child('lockers');
    DataSnapshot snapshot = await reference.get();

    if (snapshot.value != null && snapshot.value is Map) {
      Map<dynamic, dynamic>? lockersData = snapshot.value as Map?;

      // Iterate through the lockers and access their data
      lockersData!.forEach((lockerKey, lockerValue) async {

        String user = lockerValue['user'];
        if (user == result) {
          lockerName = lockerKey;
        }
        DatabaseReference lockerRef = reference.child(lockerName!);
        await lockerRef.update({'user': '', 'availability': 'yes'});
    // Check if the value is not null and is a Map


        });
    }
  }


  Future<bool> isAnySubscriptionExpired() async {
    bool hasToPay = false;
    try {
      QuerySnapshot<Map<String, dynamic>> paymentSnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(result)
          .collection('paymentDetails')
          .orderBy('expireDate', descending: true)
          .limit(1)
          .get();

      if (paymentSnapshot.docs.isNotEmpty) {
        // Access the first document's data (since you used limit(1))
        Map<String, dynamic> data = paymentSnapshot.docs[0].data();

        // Access the 'expireDate' field
        dynamic expireDate = data['expireDate'];
        if (expireDate.compareTo(currentDate) > 0) {
          hasToPay = false;
        } else {
          hasToPay = true;
        }
        // Print the 'expireDate' field
        print('Expire Date: $expireDate');
      } else {
        // Handle the case where no documents match the query
        print('No documents found matching the query.');
      }

      print('Payment $hasToPay');
      print('Payment $currentDate');

      return hasToPay;
    } catch (e) {
      print('Error checking subscription status: $e');
      // Handle the error as needed
      return false;
    }
  }

  Future<bool> pushNotificationsSpecificDevice(String uid, String title, bool notify) async {
    final CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');
    DocumentSnapshot userSnapshot;

    try {
      userSnapshot = await usersCollection.doc(uid).get();
    } catch (error) {
      // Handle the error (e.g., user not found)
      return false;
    }

    // bool anySubscriptionExpired = await isAnySubscriptionExpired();

    if (userSnapshot.exists && notify) {
      role = userSnapshot.get('role');
      username = userSnapshot.get('username');
      token = userSnapshot.get('pushToken');

      // Construct the notification data
      String dataNotifications = '{ "to" : "$token",'
          ' "notification" : {'
          ' "title":"JK Fitness",'
          '"body":"Hi $username !!, $title"'
          ' }'
          ' }';

      // Send the notification using http.post
      await http.post(
        Uri.parse(Constants.BASE_URL),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key= ${Constants.KEY_SERVER}',
        },
        body: dataNotifications,
      );

      return true;
    } else {
      // Handle the case where the user document does not exist
      return false;
    }
  }

  Future<void> _calculateUserLevel() async {

    final CollectionReference<Map<String, dynamic>> attendanceCollectionRef =
    FirebaseFirestore.instance
        .collection('users')
        .doc(result)
        .collection('attendance');

    final QuerySnapshot<Map<String, dynamic>> attendanceQuerySnapshot =
    await attendanceCollectionRef.get();

    final int attendanceCount = attendanceQuerySnapshot.size;

    int calculatedUserLevel =0;

    calculatedUserLevel = attendanceCount ~/ 5;

    print('calculatedUserLevel: $calculatedUserLevel');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(result)
        .update({'level': calculatedUserLevel});
    if (mounted) {
      setState(() {
        userLevel = calculatedUserLevel;
      });
    }
    print('Attendance Count: $attendanceCount');
  }

  Duration calculateWorkingHours(List<Map<String, dynamic>> attendanceData) {
    Duration totalWorkingHours = Duration.zero;

    for (var entry in attendanceData) {
      if (entry['intime'] != null && entry['outtime'] != null) {
        Map<String, int> intimeComponents =
        extractTimeComponents(entry['intime']);
        Map<String, int> outtimeComponents =
        extractTimeComponents(entry['outtime']);

        DateTime intime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          intimeComponents['hour']!,
          intimeComponents['minute']!,
        );

        DateTime outtime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day, outtimeComponents['hour']!,
          outtimeComponents['minute']!,
        );
        totalWorkingHours += outtime.difference(intime);
      }
    }

    return totalWorkingHours;
  }

  Future<int> getCurrentAttendanceCount(String role) async {
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: role)
        .get();

    int totalCount = 0;

    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userDoc.id)
          .collection('attendance')
          .where('date', isEqualTo: currentDate.toString())
          .where('availability', isEqualTo: "Yes")
          .get();
      totalCount += attendanceSnapshot.docs.length;
    }
    return totalCount;
  }

  Future<List<String>> getCurrentAvailableCoachIds() async {
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: "coach")
        .get();

    List<String> coachIds = [];

    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userDoc.id)
          .collection('attendance')
          .where('date', isEqualTo: currentDate.toString())
          .where('availability', isEqualTo: "Yes")
          .get();

      if (attendanceSnapshot.docs.isNotEmpty) {
        String userId = userDoc.id; // Fetch the user ID of available coach
        coachIds.add(userId);
      }
    }

    return coachIds;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (mounted) {
        setState(() {
          result = scanData.code!;
        });
      }
    });
  }

  Future<void> handleButtonPress(String attendanceType) async {
    if (result.isNotEmpty) {
      //Collection reference for users

      print('Currentdate: $currentDate');
      // int currentAttendanceCount = await getCurrentAttendanceCount();
      CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
      DocumentReference userDoc = usersCollection.doc(result);
      userDoc.get().then((userSnapshot) async {
        role = userSnapshot.get('role');
        username = userSnapshot.get('username');
        token = userSnapshot.get('pushToken');

        print('Role name :$role');
        print('Role name :$username');
        print('Role name :$token');

        DocumentReference attendanceDoc =
        userDoc.collection('attendance').doc(currentDate);

        if (role == 'coach') {
          DocumentSnapshot attendanceSnapshot = await attendanceDoc.get();
          List<Map<String, dynamic>> attendanceData = [];
          if (attendanceSnapshot.exists) {
            Map<String, dynamic>? data =
            attendanceSnapshot.data() as Map<String, dynamic>?;

            if (data != null && data['attendance_data'] is List) {
              List<dynamic> dataList = data['attendance_data'] as List<dynamic>;
              attendanceData = dataList
                  .map((item) =>
              Map<String, dynamic>.from(item as Map<String, dynamic>))
                  .toList();
            }
          }

          bool isCheckedIn = false;
          if (attendanceData.isNotEmpty) {
            Map<String, dynamic> lastEntry = attendanceData.last;
            isCheckedIn =
                lastEntry['intime'] != null && lastEntry['outtime'] == null;
          }

          DateTime currentTimeDateTime = DateTime.now();

          if (isCheckedIn) {
            // The coach is already checked in, so check if the next 'intime' is greater than the previous 'outtime'
            if (attendanceData.length < 2 ||
                attendanceData.last['outtime'] == null ||
                currentTimeDateTime
                    .isAfter(DateTime.parse(attendanceData.last['outtime']))) {
              // The next 'intime' value is valid, so add the 'outtime' value when the "out button" is pressed
              if (attendanceType == 'Out') {
                attendanceData.last['outtime'] = currentTime;
              }
            } else {
              // The next 'intime' value is not valid as it is before the previous 'outtime'
              // You may show an error message or handle this scenario accordingly.
            }
          } else {
            // The coach is not checked in, so add a new entry with 'intime' when the "in button" is pressed
            if (attendanceType == 'In') {
              attendanceData.add({
                'intime': currentTime,
                'outtime': null, // Use null for initial 'outtime' value
              });
            }
          }

          // Calculate overall 'availability' status based on the last entry
          bool isAvailable = attendanceData.isNotEmpty &&
              attendanceData.last['outtime'] == null;

          await attendanceDoc.set({
            'date': currentDate,
            'availability': isAvailable ? "Yes" : "No",
            'attendance_data': attendanceData,
          }, SetOptions(merge: true)).then((_) {
            print('Attendance document created/updated successfully');
          }).catchError((error) {
            print('Failed to create/update attendance document: $error');
          });

          Duration totalWorkingHours = calculateWorkingHours(attendanceData);
          int hours = totalWorkingHours.inHours;
          int minutes = totalWorkingHours.inMinutes % 60;
          print(
              'Total Working Hours: $hours:${minutes.toString().padLeft(2, '0')}');

          // Duration totalWorkingHoursPerDay = calculateWorkingHours(attendanceData);

          // Update the 'totalWorkingHours' field in Firestore
          await attendanceDoc.set({
            'totalWorkingHours':
            '$hours:${minutes.toString().padLeft(2, '0')}', // Store the total minutes
          }, SetOptions(merge: true)).then((_) {
            print('Total working hours updated successfully');
          }).catchError((error) {
            print('Failed to update total working hours: $error');
          });

        } else if (role == 'user') {
          DocumentSnapshot attendanceSnapshot = await attendanceDoc.get();
          Map<String, dynamic>? attendanceData =
          attendanceSnapshot.data() as Map<String, dynamic>?;



          if (attendanceData != null) {
            // Check if 'intime' is already set, and only set it if it's not already present
            if (attendanceData['intime'] == null) {
              if (attendanceType == 'In') {
                print('object');
                print('object $token ------------------------------------');

                await attendanceDoc.set({
                  'intime': currentTime,
                  'availability': "Yes",
                  'date': currentDate,
                }, SetOptions(merge: true)).then((_) {
                  print('Attendance document created/updated successfully');
                }).catchError((error) {
                  print('Failed to create/update attendance document: $error');
                });
              }
            } else {
              // Check if 'outtime' is already set, and only set it if it's not already present and 'intime' < 'outtime'
              if (attendanceData['outtime'] == null) {
                if (attendanceType == 'Out') {
                  DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(result);
                  DocumentSnapshot userSnapshot = await userDocRef.get();
                  Map<String, dynamic>? userData =
                  userSnapshot.data() as Map<String, dynamic>?;
                  DatabaseReference reference = FirebaseDatabase.instance.reference().child('users').child(result);
                  if (userData != null && userData['categorySet'] != null) {
                    int currentCategorySet = userData['categorySet'];

                    int newCategorySet = (currentCategorySet % 3) + 1;
                    await userDocRef.update({'categorySet': newCategorySet});
                    reference.update({'categorySet': newCategorySet})
                        .then((_) {
                      print('categorySet updated in Realtime Database.');
                    });
                  } else {
                    // Handle the scenario where user data or categorySet is missing
                    print('User data or categorySet is missing.');
                  }

                  await attendanceDoc.set({
                    'outtime': currentTime,
                    'availability': "No",
                  }, SetOptions(merge: true)).then((_) {
                    print('Attendance document created/updated successfully');
                  }).catchError((error) {
                    print(
                        'Failed to create/update attendance document: $error');
                  });
                   releaseLockerIfUserIsOut() ;
                } else {
                  // Show an error message or handle the scenario where 'outtime' should be after 'intime'
                }
              } else {
                // 'outtime' is already set, so no further action needed
              }
            }
          } else {
            // If the attendance document doesn't exist, set 'intime' for the first time
            if (attendanceType == 'In') {
              print('print');
              print('print $token ------------------------------------');
              await attendanceDoc.set({
                'intime': currentTime,
                'availability': "Yes",
                'date': currentDate,
              }, SetOptions(merge: true)).then((_) {
                print('Attendance document created/updated successfully');
              }).catchError((error) {
                print('Failed to create/update attendance document: $error');
              });
              //
               print('Kamm : $result');
                await pushNotificationsSpecificDevice(result, "Your have to pay !!", await isAnySubscriptionExpired());

              int remainingDays = await isChallengeAccepted();
              print("days $remainingDays");

              if (remainingDays > 0) {
                hasToRemind = true;
                await pushNotificationsSpecificDevice(result, "$remainingDays days to finish the challenge", hasToRemind);
              }
              assignLockerToCurrentUser();
              await _calculateUserLevel();
            }
          }
        }

        final DatabaseReference attendanceCountRef =
        FirebaseDatabase.instance.reference().child('attendanceCount');

        int updatedAttendanceCount = 0;

        String roles = "";

        if (role == 'user') {
          updatedAttendanceCount = await getCurrentAttendanceCount('user');
          roles = "userCount";

        } else if (role == 'coach') {
          updatedAttendanceCount = await getCurrentAttendanceCount('coach');

          roles = "coachCount";
        }
        print('count: $updatedAttendanceCount');
        attendanceCountRef.child(roles).set(updatedAttendanceCount).then((_) {
          print('Updated Attendance Count in Realtime Database');
        }).catchError((error) {
          print('Failed to update Attendance Count: $error');
        });

        final DatabaseReference availableCoachRef =
        FirebaseDatabase.instance.reference().child('availableCoach');
        List<String> coachIds = await getCurrentAvailableCoachIds();
        print('Names: $coachIds');
        //
        // List<Map<String, String>> serializedCoaches = coachIds.map((coachId) {
        //   return {'uid': coachId};
        // }).toList();

        availableCoachRef.set(coachIds).then((_) {
          print('Updated available coaches in Realtime Database');
        }).catchError((error) {
          print('Failed to update available coaches: $error');
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentTime = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Scanner"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "Scan Result: $result",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70,
                    ),
                    onPressed: () async{
                      handleButtonPress("In");
                      String uid = await SharedPreferencesUtil.getUser() ?? '';
                      await  pushNotificationsSpecificDevice(uid, "This member has to pay !!", await isAnySubscriptionExpired());

                    },
                    child: Text("In", style: TextStyle(color: Colors.black),),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70,
                    ),
                    onPressed: () {
                      handleButtonPress("Out");

                    },
                    child: Text("Out", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => ViewDetails(uid : result,
                      )));

                    },
                    child: Text("View Details", style: TextStyle(color: Colors.black)),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
