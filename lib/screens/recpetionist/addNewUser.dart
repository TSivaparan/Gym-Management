import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../reusable_widgets/reusable_widgets.dart';
import '../signin.dart';

class AddNewUser extends StatefulWidget {
  const AddNewUser({Key? key}) : super(key: key);

  @override
  State<AddNewUser> createState() => _AddNewUserState();
}

class _AddNewUserState extends State<AddNewUser> {
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _confirmPasswordTextController =
      TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _addressTextController = TextEditingController();
  TextEditingController _phoneNumberTextController = TextEditingController();
  TextEditingController _roleTextController = TextEditingController();
  TextEditingController _dobTextController = TextEditingController();
  TextEditingController _medicalInformationTextController =
      TextEditingController();

  List<TextInputFormatter> usernameInputFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
  ];
  List<TextInputFormatter> passwordInputFormatter = [];
  List<TextInputFormatter> emailInputFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
  ];
  List<TextInputFormatter> phoneNumberInputFormatter = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10), // Limit to 10 digits
    // You can also use a custom formatter to add dashes or spaces for formatting
    CustomTextInputFormatter(mask: 'xxx-xxx-xxxx', separator: '-'),
  ];
  List<TextInputFormatter> addressInputFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 .,-]')),
  ];

  bool _isPasswordVisible = false;
  bool _isPasswordMatch = true;
  File? _pickedImage;
  String selectedValue = "user";
  String? pushToken;
  int? categorySet = 1;

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("User"), value: "user"),
      DropdownMenuItem(child: Text("Receptionist"), value: "receptionist"),
      DropdownMenuItem(child: Text("Coach"), value: "coach"),
    ];
    return menuItems;
  }

  Future<void> PushToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    setState(() {
      pushToken = fcmToken;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // final pickedImage = await picker.getImage(source: ImageSource.gallery);
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        TextButton(
          onPressed: _pickImage,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.1),
                backgroundImage:
                    _pickedImage != null ? FileImage(_pickedImage!) : null,
                child: _pickedImage == null
                    ? Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white70,
                      )
                    : null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(Icons.camera_alt),
                  Text(
                    'Pick Profile',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    _dobTextController.text = ""; //set the initial value of text field
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Create new user",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.1,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                _buildImagePicker(),
                const SizedBox(height: 20), // Add the image picker widget here
                reusableTextField("Enter Username", Icons.person_outline, false,
                    _userNameTextController, usernameInputFormatter),
                const SizedBox(height: 20),
                reusableTextField("Enter Email Id", Icons.mail_outline, false,
                    _emailTextController, emailInputFormatter),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outlined,
                  !_isPasswordVisible,
                  _passwordTextController,
                  passwordInputFormatter,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Password again",
                  Icons.lock_outlined,
                  !_isPasswordVisible,
                  _confirmPasswordTextController,
                  passwordInputFormatter,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                if (!_isPasswordMatch)
                  const SizedBox(
                    height: 20,
                    child: Text(
                      "Passwords do not match",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                reusableTextField("Enter Address", Icons.home, false,
                    _addressTextController, addressInputFormatter),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Phone number",
                  Icons.phone,
                  false,
                  _phoneNumberTextController,
                  phoneNumberInputFormatter,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField(
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person_rounded,
                        color: Colors.white70,
                      ), //icon of text field

                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white12.withOpacity(0.1),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none)),
                    ),
                    dropdownColor: Colors.black,
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                      });
                    },
                    items: dropdownItems),

                const SizedBox(height: 20),
                // reusableTextField(
                //   "Enter DOB('YYYY-MM-DD')",
                //   Icons.date_range,
                //   false,
                //   _dobTextController,
                // ),
                TextField(
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  controller:
                      _dobTextController, //editing controller of this TextField
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                    ), //icon of text field
                    labelText: "Date of Birth",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white12.withOpacity(0.1),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                            width: 0, style: BorderStyle.none)),
                    // suffixIcon: suffixIcon,
                  ),
                  readOnly:
                      true, //set it true, so that user will not able to edit text
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(
                            1960), //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime.now());

                    if (pickedDate != null) {
                      print(
                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      print(
                          formattedDate); //formatted date output using intl package =>  2021-03-16
                      //you can implement different kind of Date Format here according to your requirement

                      setState(() {
                        _dobTextController.text =
                            formattedDate; //set output date to TextField value.
                      });
                    } else {
                      print("Date is not selected");
                    }
                  },
                ),

                const SizedBox(height: 20), // Add the image picker widget here
                reusableMulitpleLineField(
                  "Enter medical issues",
                  Icons.medical_services_outlined,
                  _medicalInformationTextController,
                ),

                const SizedBox(height: 20),
                signInSignUpButton(context, 'Create User', () {

                  if (_userNameTextController.text.isEmpty ||
                      _emailTextController.text.isEmpty ||
                      _passwordTextController.text.isEmpty ||
                      _confirmPasswordTextController.text.isEmpty ||
                      _addressTextController.text.isEmpty ||
                      _phoneNumberTextController.text.isEmpty ||
                      _dobTextController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  } else if (_passwordTextController.text !=
                      _confirmPasswordTextController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Passwords do not match')),
                    );
                    return;
                  }

                  if (_pickedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please pick an image')),
                    );
                    return;
                  }


                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: _emailTextController.text,
                    password: _passwordTextController.text,
                  )
                      .then((value) {
                    // PushToken();
                    // pushToken = await FirebaseMessaging.instance.getToken();
                    String? uid = value.user?.uid;
                    String? email = value.user?.email;
                    String? username = _userNameTextController.text;
                    String address = _addressTextController.text;
                    String phone_no = _phoneNumberTextController.text;
                    String dob = _dobTextController.text;
                    String medical_issues =
                        _medicalInformationTextController.text;

                    //Save the user data to the firestore db
                    CollectionReference usersCollection =
                        FirebaseFirestore.instance.collection('users');
                    usersCollection.doc(uid).set({
                      'username': username,
                      'email': email,
                      'address': address,
                      'phone_no': phone_no,
                      'role': selectedValue,
                      'categorySet': categorySet,
                      'dob': dob,
                      'expirationStatus':'Active',
                      'medical_issues': medical_issues ?? "N/A" ,
                    }).then((_) {
                      // Upload the image to Firebase Storage
                      String imagePath = 'user_profile_images/$uid';
                      final uploadTask = FirebaseStorage.instance
                          .ref()
                          .child(imagePath)
                          .putFile(_pickedImage!);

                      // Get the image URL and update the Firestore document
                      uploadTask.then((snapshot) async {
                        String imageUrl = await snapshot.ref.getDownloadURL();
                        usersCollection.doc(uid).update({'imageUrl': imageUrl});
                      });

                      print("Created New account");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Account created successfully!')),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddNewUser()),
                      );
                    }).onError((error, stackTrace) {
                      print("Error ${error.toString()}");
                    });
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
