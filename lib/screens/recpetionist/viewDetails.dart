import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../models/coach.dart';
import '../../models/viewCoachSalary.dart';

class ViewDetails extends StatefulWidget {
  final String uid;

  ViewDetails({required this.uid});

  @override
  _ViewDetailsState createState() => _ViewDetailsState();
}

class _ViewDetailsState extends State<ViewDetails> {
  final TextEditingController _paymentAmountController =
  TextEditingController();
  bool _paymentMade = false;
  String currentDate = DateTime.now().toString().split(' ')[0];
  double packagePrice = 0.0;
  double balance = 0.0;
  String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
  double packageDuration = 0.0;
  String expiryDate = '';
  String paidDate = '';
  String currentUserRole = '';

  @override
  void initState() {
    super.initState();
    fetchPaymentDetails();
    fetchPackageData();
    fetchUserRole();
  }

  void fetchPaymentDetails() async {
    print("fetchPaymentDetails-------------------------------------");

    try {
      QuerySnapshot<Map<String, dynamic>> paymentSnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('paymentDetails')
          .where('expireDate', isGreaterThan: currentDate)
          .orderBy('expireDate', descending: true)
          .limit(1)
          .get();

      if (paymentSnapshot.docs.isNotEmpty) {
        var paymentData = paymentSnapshot.docs[0].data();
        print("Payment Data: $paymentData");

        if (paymentData.containsKey('paymentAmount')) {
          setState(() {
            _paymentAmountController.text =
                paymentData['paymentAmount'].toString();
            expiryDate = paymentData['expireDate'];
            paidDate = paymentData['paidDate'];
            _paymentMade = true;
          });
        }
      }
    } catch (error) {
      print("Error fetching payment details: $error");
    }
  }

  void fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    print("fetchUserRole-------------------------------------");

    if (user != null) {
      // Get the user's UID
      final uid = user.uid;

      // Query Firestore to get the user's role based on their UID
      final userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        if (userData != null && userData['role'] != null) {
          // Store the user's role in the currentUserRole variable
          currentUserRole = userData['role'];
          print(currentUserRole);
        }
      }
    }
  }

  void fetchPackageData() async {
    // Renamed fetchPackagePrice to fetchPackageData
    print("fetchPackageData-------------------------------------");
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var userData = snapshot.data();
      if (userData != null && userData['PackageName'] != null) {
        QuerySnapshot<Map<String, dynamic>> packageSnapshot =
        await FirebaseFirestore.instance
            .collection('packages')
            .where('packageName', isEqualTo: userData['PackageName'])
            .limit(1)
            .get();

        if (packageSnapshot.docs.isNotEmpty) {
          var packageData = packageSnapshot.docs[0].data();
          var price = packageData['price'];
          var duration =
          packageData['duration']; // New line to fetch package duration

          setState(() {
            packagePrice = double.parse(price);
            packageDuration = double.parse(duration); // Store package duration
          });
        }
      }
    } catch (error) {
      print("Error fetching package data: $error");
    }
  }

  void savePaymentDetails() async {
    var expiryDate = calculateExpiryDate();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('paymentDetails')
          .doc(currentDate)
          .set({
        'paymentAmount': double.parse(_paymentAmountController.text),
        'paidDate': currentDate,
        'expireDate': expiryDate,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment details saved')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => this.widget),
      );
    } catch (error) {
      print("Error saving payment details: $error");
    }
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Details'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .get(),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator());
          // }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available'));
          }

          var userData = snapshot.data!.data();
          if (userData == null) {
            return Center(child: Text('User data is null'));
          }

          if (userData['role'] != 'user') {
            return Center(child: Text('Invalid user role'));
          }
          print(currentUserRole);
          var dobString = userData['dob'] as String;
          var dob = DateTime.parse(dobString);
          var age = DateTime.now().year - dob.year;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Username: ${userData['username']}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Package Name: ${userData['PackageName']}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Coach Name: ${userData['coachName']}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Selected Category: ${userData['SelectedCategory']}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Date of Birth: ${DateFormat('yyyy-MM-dd').format(dob)}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Age: $age years',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Phone Number: ${userData['phone_no']}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),

                Text(
                  'Medical issues: ${userData['medical_issues']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  'Package Price: $packagePrice',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Package Duration: $packageDuration months',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                if (currentUserRole == 'receptionist')
                  if (expiryDate.compareTo(currentDate) >
                      0) // Display only if payment is made and package duration is set
                    Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Payment Amount: ${_paymentAmountController.text}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Expiry Date: $expiryDate',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Payment made on : $paidDate',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ), // Display expiry date based on package duration
                      ],
                    ),
                if (currentUserRole == 'receptionist')
                if (expiryDate.compareTo(currentDate) < 0) // Check if expiryDate is greater than currentDate
                  Column(
                    children: [
                      TextFormField(
                        controller: _paymentAmountController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Payment Amount',
                          labelStyle: TextStyle(
                              color: Colors.white), // Change label text color
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white), // Change controller color
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Change controller color when focused
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff9b1616),
                        ),
                        onPressed: savePaymentDetails,
                        child: Text('Save Payment'),
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

  String calculateExpiryDate() {
    var currentDate = DateTime.now();
    var expiryDate = currentDate.add(Duration(
        days: packageDuration.toInt() * 30)); // Assuming 30 days per month
    return DateFormat('yyyy-MM-dd').format(expiryDate);
  }
}
