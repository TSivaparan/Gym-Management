import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../models/coach.dart';
import '../../models/viewCoachSalary.dart';

class CoachSalary extends StatefulWidget {
  @override
  _CoachSalaryState createState() => _CoachSalaryState();
}

class _CoachSalaryState extends State<CoachSalary> {
  var workingHours;
  String? docid;
  double totalWorkingHoursByCoach = 0.0;

  @override
  void initState() {
    super.initState();
  }

  final String uid = FirebaseAuth.instance.currentUser!.uid;
  String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
  bool showPastSalaries = false;

  Future<List<ViewCoachSalary>> _viewDetails() async {
    List<ViewCoachSalary> details = [];

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('coachSalary')
        .doc(uid)
        .collection('monthSalary')
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

    // Filter data based on the showPastSalaries flag
    if (!showPastSalaries) {
      details =
          details.where((detail) => detail.monthYear == currentMonth).toList();
    }
    details.sort((a, b) => b.monthYear.compareTo(a.monthYear));
    return details;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coach Salary'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Coach Salary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
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
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: salaryDetails.length,
                    itemBuilder: (context, index) {
                      final detail = salaryDetails[index];
                      return Card(
                        child: Container(
                          height: 150.0,
                          width: 150.0,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: new Offset(-10.0, 10.0),
                                blurRadius: 20.0,
                                spreadRadius: 3.0,
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                detail.monthYear,
                                style: TextStyle(
                                    height: 2,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                detail.Salary,
                                style: TextStyle(
                                    height: 2,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                detail.workingTime,
                                style: TextStyle(
                                    height: 2,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Salary Status : ${detail.paymentStatus}',
                                style: TextStyle(
                                  height: 2,
                                  fontWeight: FontWeight.bold,
                                  color: detail.paymentStatus == 'Settled'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff9b1616),
              ),
              onPressed: () {
                setState(() {
                  showPastSalaries = !showPastSalaries;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  showPastSalaries
                      ? 'Hide Past Salaries'
                      : 'View Last Months Salaries',
                  style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
