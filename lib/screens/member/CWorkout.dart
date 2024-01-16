import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sample_app/screens/member/workout_page.dart';

import '../../utils/sharedPrefencesUtil.dart';
import 'setOfWorkout.dart';
import 'workoutHistory.dart';

class CWorkout extends StatefulWidget {
  const CWorkout({Key? key}) : super(key: key);

  @override
  State<CWorkout> createState() => _CWorkoutState();
}

class _CWorkoutState extends State<CWorkout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String uid;
  String? categorySet;
  String? email;
  List<Map<String, dynamic>> categoryContainers = [];

  @override
  void initState() {
    _loadUserData();
    List<String> categories = categorySet?.split(',') ?? [];
    if (categories.isEmpty) {
      categories = ['abs', 'chest']; // You can set a default tab label
    }
    _tabController =
        TabController(vsync: this, length: categories.length, initialIndex: 0);
    super.initState();
  }

  @override
  void dispose() {
    _tabController
        .dispose(); // Don't forget to dispose of the TabController when it's no longer needed
    super.dispose();
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
          categorySet = userData!['categorySet'].toString();
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

          setState(() {});
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.black,
        //   elevation: 0.0,
        //   centerTitle: true,
        //   leading: IconButton(
        //     onPressed: () {},
        //     icon: Icon(Icons.arrow_back),
        //   ),
        //   title: Text(
        //     'Workouts',
        //     style: TextStyle(
        //         fontFamily: 'Varela', fontSize: 20.0, color: Color(0xFF545D68)),
        //   ),
        //   actions: <Widget>[
        //     IconButton(
        //         onPressed: () {},
        //         icon: Icon(
        //           Icons.notifications_none,
        //           color: Color(0xFF545D68),
        //         ))
        //   ],
        // ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 15.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                onPressed: () async {
                  String uid = await SharedPreferencesUtil.getUser() ?? '';
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WorkoutHistoryPage(uid: uid)));
                },
                child: const Text('workout history'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                onPressed: () {
                  // // print("Category---------------- $email");
                  // // print("Category---------------- $categorySet");
                  // _fetchCategorySet();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SetOfExercises()));
                },
                child: const Text('Cat set'),
              ),
              Text(
                'Categories',
                style: TextStyle(
                  fontFamily: 'Varela',
                  fontSize: 42.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              if (categoryContainers.isNotEmpty)
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.red,
                  labelColor: Color(0xFFC88D67),
                  isScrollable: true,
                  labelPadding: EdgeInsets.only(right: 45.0),
                  unselectedLabelColor: Color(0xFFCDCDCD),
                  tabs: categoryContainers.map((categoryData) {
                    String categoryName = categoryData['category'];
                    return Tab(
                      child: Text(
                        categoryName,
                        style: TextStyle(fontFamily: 'Varela', fontSize: 21.0),
                      ),
                    );
                  }).toList(),
                ),
              if (categoryContainers.isNotEmpty)
                Container(
                  height: MediaQuery.of(context).size.height - 50.0,
                  width: double.infinity,
                  child: TabBarView(
                    controller: _tabController,
                    children: categoryContainers.map((categoryData) {
                      String categoryName = categoryData['category'];
                      return Workouts(category: categoryName, uid: "");
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {},
        //   backgroundColor: Color(0xFFF17532),
        //   child: Icon(Icons.fastfood),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // bottomNavigationBar: BottomBar(),
      ),
    );
  }
}
