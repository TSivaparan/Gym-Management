import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sample_app/screens/coach/trainedUsers.dart';

import '../qr_screen.dart';
import '../signin.dart';
import 'addNutrition.dart';
import 'coachAddWorkout.dart';
import 'coachCheckProgress.dart';
import 'coachHomeScreen.dart';
import 'coachProfileScreen.dart';
import 'coachSalary.dart';
import 'trainedUsers.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({Key? key}) : super(key: key);

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens2 = [
    CoachHomeScreen(),
    CoachAddWorkout(),
    AddNutritionItemForm(),
    TrainingPage(),
    CoachProfileScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: Image.asset(
            'assets/images/jk fitness.jpg',
            width: 40, // Adjust the size as needed
          ),
          // title: Text("JK Fitness"),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => QRScreen()));
                },
                icon: Icon(Icons.qr_code))
          ],
        ),
        body: Center(
          child: IndexedStack(
            index: _selectedIndex,
            children: _screens2,
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.black,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            child: GNav(
              backgroundColor: Colors.black,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.grey.shade800,
              padding: EdgeInsets.all(16),
              gap: 10,
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: "Home",
                ),
                GButton(
                  icon: Icons.add,
                  text: "Add",
                ),
                GButton(
                  icon: Icons.pie_chart,
                  text: "Nutrition",
                ),
                GButton(
                  icon: Icons.bar_chart,
                  text: "Mark",
                ),
                GButton(
                  icon: Icons.person,
                  text: "Profile",
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
