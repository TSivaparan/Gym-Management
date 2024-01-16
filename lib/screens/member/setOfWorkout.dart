import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/sharedPrefencesUtil.dart';
import 'workout_page.dart';

class SetOfExercises extends StatefulWidget {
  const SetOfExercises({Key? key}) : super(key: key);

  @override
  State<SetOfExercises> createState() => _SetOfExercisesState();
}

class _SetOfExercisesState extends State<SetOfExercises> {
  late TabController _tabController;
  late String uid;
  String? categorySet;
  String? email;
  List<Map<String, dynamic>> categoryContainers = [];

  @override
  void initState() {
    super.initState();
    // Call getWorkouts() once during initialization
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    uid = await SharedPreferencesUtil.getUser() ?? '';
    try {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      DocumentSnapshot userSnapshot = await userDocRef.get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;
        setState(() {
          categorySet = userData!['categorySet'];
          email = userData['email'];
        });

        await _fetchCategories();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      DocumentReference exerciseSet = FirebaseFirestore.instance
          .collection('setOfExercise')
          .doc(categorySet);

      DocumentSnapshot exerciseSnapshot = await exerciseSet.get();
      if (exerciseSnapshot.exists) {
        Map<String, dynamic>? catData =
            exerciseSnapshot.data() as Map<String, dynamic>?;

        if (catData != null) {
          List<dynamic> categories = catData['category'] ?? [];

          for (String category in categories) {
            Map<String, dynamic> data = {'category': category};
            categoryContainers.add(data);
          }

          setState(() {
            // No need to assign categories.toString() to categorySet
          });
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: ListView.builder(
        itemCount: categoryContainers.length,
        itemBuilder: (context, index) {
          String categoryValue = categoryContainers[index]['category'];

          return ListTile(
            title: Text(categoryValue),
          );
        },
      ),
    );
  }
}
