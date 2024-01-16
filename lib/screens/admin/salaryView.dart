import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class SalaryView extends StatelessWidget {
  Future<QuerySnapshot> getCoachesQuery() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'coach')
        .get();
  }

  Future<QuerySnapshot> getAttendanceDataForCoach(String coachUid) {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    String formattedFirstDay = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    String formattedLastDay = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);
    String current = DateFormat('yyyy-MM').format(DateTime.now());

    print('currnt----$current');

    print('------------------$coachUid');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(coachUid)
        .collection('attendance')
        // .where('date', isGreaterThanOrEqualTo: formattedFirstDay)
        // .where('date', isLessThanOrEqualTo: formattedLastDay)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coaches Attendance Table'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: getCoachesQuery(),
        builder: (context, coachesSnapshot) {
          if (coachesSnapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading indicator while data is fetched.
          }

          if (coachesSnapshot.hasError) {
            return Text('Error: ${coachesSnapshot.error}');
          }

          List<DataColumn> columns = [
            DataColumn(label: Text('Coach Name')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Total Working Hours')),
          ];

          List<DataRow> rows = [];

          coachesSnapshot.data!.docs.forEach((coachDoc) async {
            String coachUid = coachDoc.id;

            String coachName = coachDoc['username'];

            QuerySnapshot attendanceQuerySnapshot =
                await getAttendanceDataForCoach(coachUid);

            attendanceQuerySnapshot.docs.forEach((attendanceDoc) {
              String date = attendanceDoc.id;
              double totalWorkingHours = attendanceDoc['totalWorkingHours'];

              rows.add(DataRow(cells: [
                DataCell(Text(coachName)),
                DataCell(Text(date)),
                DataCell(Text(totalWorkingHours.toString())),
              ]));
            });
          });

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: columns,
                rows: rows,
              ),
            ),
          );
        },
      ),
    );
  }
}
