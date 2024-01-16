import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sample_app/screens/member/prog.dart';
import 'package:sample_app/screens/member/nutrition.dart';

class BMICalculator extends StatefulWidget {
  const BMICalculator({Key? key}) : super(key: key);

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  double _height = 170.0;
  double _weight = 75.0;
  double bmi = 0.0;
  String _condition = "Your Category";

  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();

  String? email;
  String? address;
  String? uid;
  get bmiValue => bmi;
  String curdate = DateTime.now().toString().split(' ')[0];
  @override
  Widget build(BuildContext context) {
    // final bool isAdult = true;
    Size size = MediaQuery.of(context).size;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    uid = user?.uid;
    // email = user?.email;

    if (uid != null) {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      userDocRef.get().then((DocumentSnapshot documentSnapshot) {
        if (mounted) {
          Map<String, dynamic>? userData =
              documentSnapshot.data() as Map<String, dynamic>?;
          setState(() {
            email = userData!['email'];
            address = userData['address'];
          });
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white24,
        title: Text("Calculator"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(color: Colors.white12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              child: Row(
                                children: [
                                  Container(
                                      height: 150.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff9b1616),
                                        border: Border.all(
                                          color: Colors.black12,
                                          width: 6,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xff9b1616)
                                                .withOpacity(0.3),
                                            offset: new Offset(10.0, 10.0),
                                            blurRadius: 2.0,
                                            spreadRadius: 3.0,
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3.0, horizontal: 70.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              "BMI  :",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 40,
                                            ),
                                            Text(
                                              "$bmi",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 30,
                                                fontFamily: 'RobotoMono',
                                              ),
                                              textAlign: TextAlign.end,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              'kg/m2 ',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white70,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  // const Text('Female',style: TextStyle(fontSize: 30),),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 80.0,
                            top: 50.0,
                          ),
                          child: Container(
                            height: 50,
                            child: Text(
                              "Category : $_condition",
                              style: TextStyle(
                                fontSize: 25,
                                fontFamily: 'RobotoMono',
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xf2ffffff),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                  width: double.infinity,
                  // height: 800,
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.02),
                      RichText(
                        text: TextSpan(
                          text: "Height : ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30.0,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: "$_height cm",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 300,
                              child: TextField(
                                controller: _heightController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 3,
                                        color: Colors.black), //<-- SEE HERE
                                  ),
                                  hintText: 'Enter height in cm',
                                  hintStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 60),
                                ),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _height = double.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      RichText(
                        text: TextSpan(
                          text: "Weight : ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30.0,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: "$_weight kg",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width:
                                  300, // Set the desired width for the TextField
                              child: TextField(
                                controller: _weightController,
                                textAlign: TextAlign.center,
                                // TextEditingController to manage the input value
                                // keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 3,
                                        color: Colors.black), //<-- SEE HERE
                                  ),
                                  hintText: 'Enter weight in kg',
                                  hintStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 60),
                                ),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                onChanged: (value) {
                                  // Update the weight value when the TextField value changes
                                  setState(() {
                                    _weight = double.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Container(
                // width: size.width * 0.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff9b1616),
                      ),
                      child: Text(
                        "Calculate",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          bmi = (_weight / ((_height / 100) * (_height / 100)))
                              .round()
                              .toDouble();
                          // if (isAdult == true) {
                          if (bmi > 18.5 && bmi <= 25) {
                            _condition = " Normal";
                          } else if (bmi > 25 && bmi <= 30) {
                            _condition = " Overweight";
                          } else if (bmi > 30) {
                            _condition = " Obesity";
                          } else {
                            _condition = " Underweight";
                          }
                        });
                        CollectionReference usersCollection =
                            FirebaseFirestore.instance.collection('users');
                        DocumentReference userDoc = usersCollection.doc(uid);
                        DocumentReference bmiDoc =
                            userDoc.collection('bmi').doc(curdate);
                        bmiDoc.set({
                          'value': bmi,
                          'time': DateTime.now(),
                          'category': _condition,
                        }).then((_) {
                          print("Created New account");
                        }).onError((error, stackTrace) {
                          print("Error ${error.toString()}");
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white38,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NutritionChart()));
                        },
                        child: const Text(
                          "View Diet Chart",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'RobotoMono',
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
