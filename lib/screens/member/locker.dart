import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/sharedPrefencesUtil.dart';

class Locker extends StatefulWidget {
  const Locker({Key? key}) : super(key: key);

  @override
  State<Locker> createState() => _LockerState();
}

class _LockerState extends State<Locker> {
  final firestoreInstance = FirebaseFirestore.instance;
  late var state = '';
  late Stream<List<Object>> lockerStream;
  final DatabaseReference databaseReference =
  FirebaseDatabase.instance.reference();

  DatabaseReference locker =
  FirebaseDatabase.instance.reference().child("lockers");

  void initState() {
    super.initState();
    locker.onValue.listen((event) {
      fetchLockers();
      setState(() {});
    });
  }

  Future<String?> fetchLockers() async {
    final userId = await SharedPreferencesUtil.getUser() ?? '';
    String? lockerName;

    try {
      DatabaseReference reference =
      FirebaseDatabase.instance.reference().child("lockers");
      DataSnapshot snapshot = await reference.get();

      if (snapshot.value != null && snapshot.value is Map) {
        Map<dynamic, dynamic>? lockersData = snapshot.value as Map?;

        // Iterate through the lockers and access their data
        lockersData!.forEach((lockerKey, lockerValue) {
          String availability = lockerValue['availability'];
          String user = lockerValue['user'];
          String status = lockerValue['status'];

          print('Locker Key: $lockerKey');
          print('Availability: $availability');
          print('User: $user');
          print('Status: $status');

          if (user == userId) {
            lockerName = lockerKey;
            state = status;
          }
        });
      } else {
        print('No data found under the "lockers" node');
      }
    } catch (error) {
      print("Error: $error");
    }

    // Return a default value or handle the case where no data was found
    return lockerName;
  }

  Future<void> openCloseLocker(String operation, String lockerKey) async {
    try {
      await databaseReference.child('lockers').child(lockerKey).update({
        'status': '$operation',
      });
    } catch (e) {
      print('Error opening locker: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width - 50,
          height: 100,
          color: Colors.white10,
          child: FutureBuilder<String?>(
            future: fetchLockers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final lockerName = snapshot.data;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Locker Name: $lockerName is  $state"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state == 'closed')
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff9b1616),
                              ),
                              onPressed: () {
                                print("$lockerName opened");
                                openCloseLocker("opened", "$lockerName");
                              },
                              child: Text('Open'),
                            ),
                          ),
                        if (state == 'opened')
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff9b1616),
                              ),
                              onPressed: () {
                                print("$lockerName closed");
                                openCloseLocker("closed", "$lockerName");
                              },
                              child: Text('Close'),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              } else {
                return Center(child: Text('User does not have a locker.',
                style: TextStyle(color: Colors.white70,
                fontSize: 15,
                  fontWeight: FontWeight.bold
                ),
                ));
              }
            },
          ),
        ),
      ),
    );
  }
}
