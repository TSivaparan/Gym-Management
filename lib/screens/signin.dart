import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample_app/screens/recpetionist/recNavigation.dart';
import 'package:sample_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../reusable_widgets/reusable_widgets.dart';

import 'coach/coachNav.dart';
import 'coach/coachSalary.dart';
import 'initialScreen.dart';
import 'member/userNav.dart';
import 'member/forgot_pw.dart';

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  List<TextInputFormatter> passwordInputFormatter = [];
  List<TextInputFormatter> emailInputFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
  ];

  String _errorMessage = '';
  SharedPreferences? _prefs;
  String? pushToken;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    super.dispose();
    _isMounted = false;
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white70,
          title: Text('JK Membership', style:TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),),
          content: Text('Your account has been expired', style:TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style:TextStyle(
                color: Color(0xff9b1616),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> setUser(String uid) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    _prefs?.setString('uid', uid);
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        "OK",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        // Navigator.pop(
        //     context, MaterialPageRoute(builder: (context) => Signin()));
        FirebaseAuth.instance.signOut();
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("JK Fitness"),
      content: Text("Your membership has been expired."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String _userRole = '';
    String _username = '';
    String _expirationStatus = 'Expired';
    String _uid = '';
    void navigateToRoleScreen() {
      if (_userRole == 'coach') {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CoachScreen()));
        // Navigator.pushNamed(context, 'coach/coachHome/coachScreen');
      } else if (_userRole == 'user') {
        if (_expirationStatus == 'Active') {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Home()));
        } else {
          // showAlertDialog(context);
          _showDialog();
        }

        // Navigator.pushNamed(context, 'member/userNav/Home');
      } else if (_userRole == 'receptionist') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ReceptionistScreen()));
        // Navigator.pushNamed(context, 'member/userNav/Home');
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, MediaQuery.of(context).size.height * 0.2, 20, 0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: CircleAvatar(
                            radius: 150.0,
                            backgroundImage:
                                AssetImage('assets/images/jk fitness.jpg'),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        reusableTextField(
                          "Enter your Email",
                          Icons.email_outlined,
                          false,
                          _emailTextController,
                          emailInputFormatter,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        reusableTextField(
                            "Enter your Password",
                            Icons.lock_outline,
                            true,
                            _passwordTextController,
                            passwordInputFormatter),
                        if (_errorMessage
                            .isNotEmpty) // Only show the error message when it's not empty
                          Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ForgotPasswordPage();
                            }));
                          },
                          child: Text(
                            'Forgot Password',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        signInSignUpButton(context, 'Sign In', () async {
                          try {
                            var userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text,
                            );

                            String? uid = userCredential.user?.uid;
                            setUser(uid!);
                            FirebaseFirestore _firestore =
                                FirebaseFirestore.instance;
                            DocumentSnapshot userSnapshot = await _firestore
                                .collection('users')
                                .doc(uid)
                                .get();

                            // for role based login
                            if (userSnapshot.exists) {
                              pushToken =
                                  await FirebaseMessaging.instance.getToken();
                              CollectionReference usersCollection =
                                  FirebaseFirestore.instance
                                      .collection('users');
                              usersCollection.doc(uid).update({
                                'pushToken': pushToken,
                              });
                              setState(() {
                                _userRole = userSnapshot['role'];
                                _username = userSnapshot['username'];
                                if (_userRole == 'user') {
                                  _expirationStatus =
                                      userSnapshot['expirationStatus'];
                                }

                                _uid = uid!;
                              });
                              navigateToRoleScreen();
                              // Initial();
                            } else {
                              // Handle user document not found error
                            }
                            if (_isMounted) {
                              setState(() {
                                _errorMessage = '';
                              });
                            }

                            _emailTextController.clear();
                            _passwordTextController.clear();
                          } catch (e) {
                            print("Error: $e");
                            if (_isMounted) {
                              setState(() {
                                _errorMessage = 'Invalid email or password';
                              });
                            }
                          }
                        }),
                      ],
                    )))),
      ),
    );
  }
}
