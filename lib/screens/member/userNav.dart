import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sample_app/screens/member/CWorkout.dart';
import 'package:sample_app/screens/member/prog.dart';
import 'package:sizer/sizer.dart';
import '../cookie/cHome.dart';
import 'addOwnWorkout.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../qr_screen.dart';
import 'workout_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
 double height = 0.0;
  // static const TextStyle optionStyle =
  //     TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final List<Widget> _screens = [
    HomeScreen(),
    CWorkout(),
    AddOwnWorkouts(),
    ChartScreen(),
    ProfileScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
              children: _screens,
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Navigator.of(context)
          //         .pop(MaterialPageRoute(builder: (context) => SecondPage()));
          //   },
          //   child: Icon(Icons.navigate_before),
          // ),
          bottomNavigationBar: Container(
            color: Colors.black,
              // width: 20.h,
              // height:30.h,

              child: Padding(
              padding:
              // const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
             EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              child: GNav(
                backgroundColor: Colors.white12,
                color: Colors.white,
                activeColor: Colors.black,
                tabBackgroundColor: Colors.white,
                padding: EdgeInsets.all(16),
                gap: 3,
                tabs: const [
                  GButton(
                    icon: Icons.home,
                    text: "Home",
                  ),
                  GButton(
                    icon: Icons.fitness_center,
                    text: "Workout",
                  ),
                  GButton(
                    icon: Icons.add,
                    text: "Add",
                  ),
                  GButton(
                    icon: Icons.bar_chart,
                    text: "Progress",
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
        ));
  }
}
