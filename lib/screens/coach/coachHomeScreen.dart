import 'package:circular_seek_bar/circular_seek_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:sample_app/screens/coach/trainedUsers.dart';

import '../../models/coach.dart';
import '../../models/viewCoachSalary.dart';
import 'coachSalary.dart';
import 'createChallenges.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({Key? key}) : super(key: key);

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  String? email;
  String? username;
  String? imageUrl;
  Stream<int>? attendanceCountStream;
  late Stream<List<Object>> availablecoachStream;
  List<String> usernames = [];

  DatabaseReference attendanceCountRef = FirebaseDatabase.instance
      .reference()
      .child('attendanceCount')
      .child('userCount');

  DatabaseReference available =
      FirebaseDatabase.instance.reference().child('availableCoach');

  final User currentUser = FirebaseAuth.instance.currentUser!;
  double _rating = 0;

  void initState() {
    super.initState();
    attendanceCountStream = attendanceCountRef.onValue.map((event) {
      return event.snapshot.value as int? ?? 0;
    });
    availablecoachStream = available.onValue.map((event) {
      List<Object> data = [];
      if (event.snapshot.value != null) {
        data = (event.snapshot.value as List<dynamic>).cast<Object>();
      }
      return data;
    });
  }

  Future<List<Coach>> _loadCoaches(List<String> coachIds) async {
    List<Coach> coaches = [];

    for (final String coachId in coachIds) {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(coachId)
          .get();
      if (snapshot.exists) {
        final Map<String, dynamic> data =
            snapshot.data() as Map<String, dynamic>;
        coaches.add(Coach(
          uid: snapshot.id,
          email: data['email'] ?? '',
          username: data['username'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        ));
      }
    }

    return coaches;
  }

  String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<ViewCoachSalary>> _viewDetails() async {
    List<ViewCoachSalary> details = [];

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('coachSalary')
        .doc(uid)
        .collection('monthSalary')
        .where('month', isEqualTo: currentMonth.toString())
        .get();

    for (final DocumentSnapshot doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final String monthYear = data['month'] ?? '';

      details.add(ViewCoachSalary(
        monthYear: monthYear,
        Salary: data['Salary '].toString(),
        workingTime: data['workingTime'] ?? '',
        paymentStatus: data['paymentStatus'],
      ));
    }

    return details;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              color: Colors.white24, // Change the color to red
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Container(
                    width: 200,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage('assets/images/chest.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Container(
                    width: 200,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage('assets/images/workout.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: 200,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage('assets/images/abs.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ), // Add more Container widgets for additional images
                ],
              ),
            ),
            StreamBuilder<int>(
              stream: attendanceCountStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int attendanceCount = snapshot.data!;
                  return Align(
                    alignment: Alignment.topRight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          // Adjust the height as desired
                          child: CircularSeekBar(
                            width: double.infinity,
                            height: 150,
                            progress: attendanceCount.toDouble(),
                            maxProgress: 20,
                            minProgress: 0,
                            barWidth: 10,
                            startAngle: 90,
                            sweepAngle: 360,
                            strokeCap: StrokeCap.butt,
                            progressColor: Color(0xFFB71C1C),
                            innerThumbRadius: 5,
                            innerThumbStrokeWidth: 3,
                            innerThumbColor: Colors.white,
                            outerThumbRadius: 10,
                            outerThumbStrokeWidth: 10,
                            outerThumbColor: Color(0xFFB71C1C),
                            animation: true,
                          ),
                        ),
                        Positioned(
                          child: Column(
                            children: [
                              Text(
                                'Current Crowd',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: 20, // Adjust the width as desired
                                height: 40, // Adjust the height as desired
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    attendanceCount != null
                                        ? '$attendanceCount'
                                        : 'N/A',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: SpinKitWaveSpinner(
                      color: Colors.white,
                      size: 50.0, // Adjust the size as desired
                    ),
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                child: StreamBuilder<List<Object>>(
                  stream: availablecoachStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Object> data = snapshot.data!;
                      List<String> coachIds = data.cast<String>();
                      if (data.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Available Coaches:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 6,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.white12,
                                    offset: Offset(
                                      10.0,
                                      10.0,
                                    ), //Offset
                                    blurRadius: 3.0,
                                    spreadRadius: 2.0,
                                  ), //BoxShadow
                                ],
                              ), // Adjust the height as needed
                              child: FutureBuilder<List<Coach>>(
                                future: _loadCoaches(coachIds),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  } else {
                                    List<Coach> coaches = snapshot.data ?? [];
                                    return GridView.builder(
                                      scrollDirection: Axis.horizontal,
                                      gridDelegate:
                                          SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 200,
                                        mainAxisExtent: 130,
                                        crossAxisSpacing: 3.0,
                                        mainAxisSpacing: 3.0,
                                      ),
                                      itemCount: coaches.length,
                                      itemBuilder: (context, index) {
                                        Coach coach = coaches[index];
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(coach.imageUrl),
                                              radius: 50,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              coach.username,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Center(
                          child: Text(
                            'No available coaches',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder<List<ViewCoachSalary>>(
              future: _viewDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  final salaryDetails = snapshot.data ?? [];
                  print('Loaded');
                  // Instead of Text("abc"), use print to display the message in the debug console.
                  return Center(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(left: 75.0, right: 75.0),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        mainAxisExtent: 250,
                      ),
                      itemCount: salaryDetails.length,
                      itemBuilder: (context, index) {
                        final detail = salaryDetails[index];
                        return Card(
                          child: Container(
                            width: 300,
                            height: 400,
                            // Set the desired width for each package box
                            decoration: BoxDecoration(
                              color: Color(0xff9b1616),
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: new Offset(-10.0, 10.0),
                                  blurRadius: 2.0,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'This month',
                                  style: TextStyle(
                                      height: 2,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                Text(
                                  detail.monthYear,
                                  style: TextStyle(
                                      height: 2, color: Colors.white70),
                                ),
                                Text(
                                  'Until today total working time :',
                                  style: TextStyle(
                                      height: 2, color: Colors.white70),
                                ),
                                Text(
                                  detail.workingTime,
                                  style: TextStyle(
                                      height: 2, color: Colors.white70),
                                ),
                                Text(
                                  'Total Payable ',
                                  style: TextStyle(
                                      height: 2, color: Colors.white70),
                                ),
                                Text(
                                  'Rs.${detail.Salary}.00 ',
                                  style: TextStyle(
                                      height: 2, color: Colors.white70),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                  ),
                                  child: Text("View Salary"),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CoachSalary()));
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff9b1616),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateChallenges()));
              },
              child: Text("Create challenges"),
            ),
          ],
        ),
      ),
    );
  }
}
