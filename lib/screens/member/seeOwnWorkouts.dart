import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/sharedPrefencesUtil.dart';
import 'ownWorkouts.dart';
import 'workout_page.dart';

class SeeOwnWorkouts extends StatelessWidget {
  const SeeOwnWorkouts({Key? key}) : super(key: key);

  Future<List<String>> fetchCategories() async {
    List<String> categories = [];

    String uid = await SharedPreferencesUtil.getUser() ?? '';

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ownWorkout')
        .get();

    snapshot.docs.forEach((doc) {
      final category = doc.get('category') as String;
      if (!categories.contains(category)) {
        categories.add(category);
      }
    });

    return categories;
  }

  @override
  Widget build(BuildContext context) {
    String userid = 'aaa';

    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        title: Text("Own workouts"),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading categories.'));
          } else {
            List<String> categories = snapshot.data ?? [];

            return GridView.count(
              scrollDirection: Axis.horizontal,
              primary: true,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 1,
              children: categories.map((category) {
                return OwnWorkouts(category: category);
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
