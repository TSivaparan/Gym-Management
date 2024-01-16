import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'TodoList.dart';

class Diet extends StatefulWidget {
  Diet({Key? key}) : super(key: key);

  @override
  _DietState createState() => _DietState();
}

class _DietState extends State<Diet> {
  final _formKey = GlobalKey<FormState>();

  /// firebase
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;

  /// form variable
  late String breakfast;
  late String lunch;
  late String dinner;
  late String kcal1, kcal2, kcal3;
  late TextEditingController breakfastTextController = TextEditingController();
  late TextEditingController lunchTextController = TextEditingController();
  late TextEditingController dinnerTextController = TextEditingController();
  late TextEditingController kcal1TextController = TextEditingController();
  late TextEditingController kcal2TextController = TextEditingController();
  late TextEditingController kcal3TextController = TextEditingController();
  // @override
  // void initState() {
  //   super.initState();
  //   // getCurrentUser();
  //   breakfastTextController = TextEditingController();
  //   lunchTextController = TextEditingController();
  //   dinnerTextController = TextEditingController();
  //   kcal1TextController = TextEditingController();
  //   kcal2TextController = TextEditingController();
  //   kcal3TextController = TextEditingController();
  // }

  // void getCurrentUser() async {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user != null) {
  //       loggedInUser = user;
  //       print(loggedInUser.email);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  void dispose() {
    breakfastTextController.dispose();
    lunchTextController.dispose();
    dinnerTextController.dispose();
    kcal1TextController.dispose();
    kcal2TextController.dispose();
    kcal3TextController.dispose();
    super.dispose();
  }

  //
  // void logout() {
  //   _auth.signOut();
  //   Navigator.pop(context);
  // }
  clearText() {
    breakfastTextController.clear();
    lunchTextController.clear();
    dinnerTextController.clear();
  }

  // Adding Student
  CollectionReference diet =
      FirebaseFirestore.instance.collection('dietChart');

  Future<void> addUser() {
    return diet
        .add({'breakfast': breakfast, 'lunch': lunch, 'dinner': dinner})
        .then((value) => print('User Added'))
        .catchError((error) => print('Failed to Add user: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Diet chart'),
        actions: <Widget>[
          //IconButton(
          // icon: Icon(Icons.close),
          //onPressed: () {
          // _auth.signOut();
          // Navigator.pop(context);
          // logout();
          //   getMessages();
          //Implement logout functionality
          // }),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: ListView(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Name: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle:
                        TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: breakfastTextController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Name';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Email: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle:
                        TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: lunchTextController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Email';
                    } else if (!value.contains('@')) {
                      return 'Please Enter Valid Email';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: [
                      TextFormField(
                        autofocus: false,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password: ',
                          labelStyle: TextStyle(fontSize: 20.0),
                          border: OutlineInputBorder(),
                          errorStyle:
                              TextStyle(color: Colors.redAccent, fontSize: 15),
                        ),
                        controller: dinnerTextController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Password';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        autofocus: false,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password: ',
                          labelStyle: TextStyle(fontSize: 20.0),
                          border: OutlineInputBorder(),
                          errorStyle:
                              TextStyle(color: Colors.redAccent, fontSize: 15),
                        ),
                        controller: dinnerTextController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Password';
                          }
                          return null;
                        },
                      ),
                    ],
                  )),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, otherwise false.
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            breakfast = breakfastTextController.text;
                            lunch = lunchTextController.text;
                            dinner = dinnerTextController.text;
                            addUser();
                            clearText();
                          });
                        }
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => {clearText()},
                      child: Text(
                        'Reset',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
    // Padding(
    //   padding: const EdgeInsets.all(24.0),
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     crossAxisAlignment: CrossAxisAlignment.stretch,
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: Text(
    //           'Add Diet Chart',
    //           textAlign: TextAlign.center,
    //           style: TextStyle(
    //             fontSize: 40,
    //             color: Colors.blue,
    //           ),
    //         ),
    //       ),
    //       TextField(
    //         controller: breakfastTextController,
    //         onChanged: (value) {
    //           breakfast = value;
    //         },
    //         decoration: InputDecoration(
    //           hintText: 'Breakfast',
    //           alignLabelWithHint: true,
    //           contentPadding:
    //               EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    //           border: OutlineInputBorder(
    //             borderRadius: BorderRadius.all(Radius.circular(10.0)),
    //           ),
    //         ),
    //       ),
    //       SizedBox(
    //         height: 8.0,
    //       ),
    //       TextField(
    //         controller: lunchTextController,
    //         onChanged: (value) {
    //           lunch = value;
    //         },
    //         decoration: InputDecoration(
    //           hintText: 'Lunch',
    //           contentPadding:
    //               EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    //           border: OutlineInputBorder(
    //             borderRadius: BorderRadius.all(Radius.circular(10.0)),
    //           ),
    //         ),
    //       ),
    //       SizedBox(
    //         height: 8.0,
    //
    //       ),
    //       TextField(
    //         controller: dinnerTextController,
    //         onChanged: (value) {
    //           dinner = value;
    //         },
    //         decoration: InputDecoration(
    //           contentPadding:
    //               EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    //           hintText: 'Dinner',
    //           border: OutlineInputBorder(
    //             borderRadius: BorderRadius.all(Radius.circular(10.0)),
    //           ),
    //         ),
    //       ),
    //       SizedBox(
    //         height: 8.0,
    //       ),
    //       TextField(
    //         controller: kcal1TextController,
    //         onChanged: (value) {
    //           kcal1 = value;
    //         },
    //         decoration: InputDecoration(
    //           contentPadding: EdgeInsets.all(10),
    //           hintText: 'kcal1',
    //           border: OutlineInputBorder(
    //             borderRadius: BorderRadius.all(Radius.circular(10.0)),
    //           ),
    //         ),
    //       ),
    //       Padding(
    //         padding: EdgeInsets.symmetric(vertical: 16.0),
    //         child: Material(
    //           // elevation: 5.0,
    //           color: Colors.lightBlueAccent,
    //           borderRadius: BorderRadius.circular(30.0),
    //           child: MaterialButton(
    //             minWidth: 200.0,
    //             height: 42.0,
    //             child: Text(
    //               'Save',
    //               style: TextStyle(color: Colors.white),
    //             ),
    //             onPressed: () async {
    //               _fireStore.collection('todo').add({
    //                 'breakfast': breakfast,
    //                 'lunch': lunch,
    //                 'dinner': dinner,
    //                 'kcal1': kcal1,
    //                 'sender': loggedInUser.email,
    //                 'created': Timestamp.now(),
    //               });
    //               breakfastTextController.clear();
    //               lunchTextController.clear();
    //               dinnerTextController.clear();
    //               kcal1TextController.clear();
    //             },
    //           ),
    //         ),
    //       ),
    //       Padding(
    //         padding: EdgeInsets.symmetric(vertical: 16.0),
    //         child: Material(
    //           elevation: 5.0,
    //           color: Colors.lightBlueAccent,
    //           borderRadius: BorderRadius.circular(30.0),
    //           child: MaterialButton(
    //             minWidth: 200.0,
    //             height: 42.0,
    //             child: Text(
    //               'Todo_List',
    //               style: TextStyle(color: Colors.white),
    //             ),
    //             onPressed: () async {
    //               Navigator.push(
    //                 context,
    //                 MaterialPageRoute(builder: (context) => TodoList()),
    //               );
    //             },
    //           ),
    //         ),
    //       )
    //     ],
    //   ),
    // ));
  }
}
