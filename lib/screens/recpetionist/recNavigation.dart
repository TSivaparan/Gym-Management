import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../member/qr_scan.dart';
import '../signin.dart';
import 'addNewUser.dart';

class ReceptionistScreen extends StatefulWidget {
  const ReceptionistScreen({Key? key}) : super(key: key);

  @override
  State<ReceptionistScreen> createState() => _ReceptionistScreenState();
}

class _ReceptionistScreenState extends State<ReceptionistScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens2 = [AddNewUser(), ReceptionistProfileScreen()];

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
          backgroundColor: Colors.white12,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => QRScan()));
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
                  icon: Icons.add,
                  text: "Add new user",
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

class ReceptionistHomeScreen extends StatefulWidget {
  const ReceptionistHomeScreen({Key? key}) : super(key: key);

  @override
  State<ReceptionistHomeScreen> createState() => _ReceptionistHomeScreenState();
}

class _ReceptionistHomeScreenState extends State<ReceptionistHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'Receptionist home',
            style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// class ReceptionistAddUser extends StatefulWidget {
//   const ReceptionistAddUser({Key? key}) : super(key: key);
//
//   @override
//   State<ReceptionistAddUser> createState() => _ReceptionistAddUserState();
// }
//
// class _ReceptionistAddUserState extends State<ReceptionistAddUser> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Center(
//           child: Text(
//             'add user Page',
//             style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     );
//   }
// }

class ReceptionistProfileScreen extends StatefulWidget {
  const ReceptionistProfileScreen({Key? key}) : super(key: key);

  @override
  State<ReceptionistProfileScreen> createState() =>
      _ReceptionistProfileScreenState();
}

class _ReceptionistProfileScreenState extends State<ReceptionistProfileScreen> {
  String? uid;
  String? username;
  String? email;
  String? phone_no;
  String? address;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the widget is created
  }

  // Method to load user data from Firebase Firestore
  Future<void> _loadUserData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      uid = currentUser.uid;
      final userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        final data = userSnapshot.data();
        if (data != null) {
          setState(() {
            email = data['email'];
            username = data['username'];
            phone_no = data['phone_no'];
            address = data['address'];
            imageUrl = data['imageUrl'];
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? uid;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(email ?? ""),
          Text(
            'Receptionist Profile Page',
            style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
          ),

          CircleAvatar(
            radius: 80,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null ? Icon(Icons.person, size: 60) : null,
          ),
          const SizedBox(height: 20),
          Text(
            '$username',
            style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            'Email: ${email ?? "N/A"}',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),
          Text(
            'Phone number: ${phone_no ?? "N/A"}',
            style: TextStyle(fontSize: 15),
          ),

          const SizedBox(height: 20),
          Text(
            'Address: ${address ?? "N/A"}',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff9b1616),
            ),
            child: Text("Logout"),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                print("Signed Out");
                setState(() {
                  uid = null;
                  email = null;
                  address = null;
                });
                // FirebaseAuth.instance.setPersistence(Persistence.NONE);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Signin()));
              });
            },
          ),
        ],
      ),
    );
  }
}