import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutHistoryPage extends StatelessWidget {
  final String uid;

  WorkoutHistoryPage({required this.uid});

  Future<List<Map<String, dynamic>>> getWorkoutHistory() async {
    try {
      // Step 1: Get a reference to the workout_history collection for the user
      CollectionReference workoutHistoryRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('workout_history');

      // Step 2: Get the documents from the workout_history collection
      QuerySnapshot querySnapshot = await workoutHistoryRef
          .orderBy('date', descending: true)
          .limit(7)
          .get();

      // Step 3: Convert the QuerySnapshot to a list of workout data
      List<Map<String, dynamic>> workoutHistoryData = [];
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        workoutHistoryData.add(data);
      });

      return workoutHistoryData;
    } catch (e) {
      print('Error fetching workout history: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getWorkoutHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading data.'),
            );
          } else {
            List<Map<String, dynamic>> workoutHistory = snapshot.data ?? [];
            return ListView.builder(
              itemCount: workoutHistory.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> workoutData = workoutHistory[index];
                String date = workoutData['date'] ?? 'Unknown Date';
                List<dynamic> exercises = workoutData['exercises'] ?? [];

                return ListTile(
                  title: Text('Date: $date'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: exercises.map((exercise) {
                      return Text('Exercise: $exercise');
                    }).toList(),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
