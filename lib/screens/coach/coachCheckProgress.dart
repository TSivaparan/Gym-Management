import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;


class CoachCheckProg extends StatelessWidget {
  final String uid;
  final String username;
  const CoachCheckProg({required this.uid, required this.username});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$username'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('bmi')
            .orderBy('time')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<BMIRecord> bmiData = [];
          DateTime currentDate = DateTime.now();

          snapshot.data!.docs.forEach((doc) {
            DateTime date = doc['time'].toDate();
            // double bmi = double.tryParse(doc['value']) ?? 0.0;
            double bmi = (doc['value'] is int)
                ? (doc['value'] as int).toDouble()
                : doc['value'] as double;

            // to show last two days' bmi
            if (date.isAfter(currentDate.subtract(Duration(days: 30)))) {
              bmiData.add(BMIRecord(date: date, bmi: bmi));
            }
          });

          return SingleChildScrollView(
            child: Row(
              children: [
                Text("BMI"),
                Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.width,
                      width: MediaQuery.of(context).size.width - 30,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: charts.TimeSeriesChart(
                          _createSeriesData(bmiData),
                          animate: true,
                          dateTimeFactory: const charts.LocalDateTimeFactory(),
                          primaryMeasureAxis: charts.NumericAxisSpec(
                            tickProviderSpec:
                            charts.BasicNumericTickProviderSpec(
                              desiredMinTickCount: 5,
                              desiredMaxTickCount: 10,
                            ),
                            renderSpec: charts.GridlineRendererSpec(
                              labelStyle: charts.TextStyleSpec(
                                color: charts.MaterialPalette.white,
                              ),
                              lineStyle: charts.LineStyleSpec(
                                color: charts.MaterialPalette.white,
                              ),
                            ),
                          ),
                          domainAxis: charts.DateTimeAxisSpec(
                            tickProviderSpec: charts.DayTickProviderSpec(
                              increments: [2],
                            ),
                            renderSpec: charts.SmallTickRendererSpec(
                              labelStyle: charts.TextStyleSpec(
                                color: charts.MaterialPalette.white,
                              ),
                              lineStyle: charts.LineStyleSpec(
                                color: charts.MaterialPalette.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text("Date"),
                    SizedBox(
                      height: 16.0,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<charts.Series<BMIRecord, DateTime>> _createSeriesData(
      List<BMIRecord> bmiData) {
    return [
      charts.Series<BMIRecord, DateTime>(
        id: 'BMI',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (BMIRecord bmiRecord, _) => bmiRecord.date,
        measureFn: (BMIRecord bmiRecord, _) => bmiRecord.bmi,
        data: bmiData,
      )
    ];
  }
}
class BMIRecord {
  final DateTime date;
  final double bmi;

  BMIRecord({required this.date, required this.bmi});
}
