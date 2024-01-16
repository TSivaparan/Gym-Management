import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NutritionItem {
  String id;
  String foodTime;
  String food;
  String category;
  String day;
  int calories;

  NutritionItem({
    required this.id,
    required this.foodTime,
    required this.food,
    required this.category,
    required this.day,
    required this.calories,
  });
}

class NutritionChart extends StatelessWidget {
  String? uid;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    uid = user?.uid;
    var cat;

    DateTime now = DateTime.now();
    String dayName = DateFormat('EEEE').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nutrition Chart',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.white12, // Set your desired background color
        elevation: 0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('nutrition_chart')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              CollectionReference userCollectionsRef = FirebaseFirestore
                  .instance
                  .collection('users')
                  .doc(uid)
                  .collection('bmi');

              return FutureBuilder<QuerySnapshot>(
                future: userCollectionsRef
                    .orderBy('time', descending: true)
                    .limit(1)
                    .get(),
                builder: (context, bmiSnapshot) {
                  if (bmiSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  var lastBmiDocument =
                      bmiSnapshot.data?.docs.isNotEmpty ?? false
                          ? bmiSnapshot.data!.docs[0]
                          : null;

                  if (lastBmiDocument != null) {
                    cat = lastBmiDocument['category'];
                    cat = cat.trim();
                  } else {
                    print('No BMI documents found.');
                  }
                  print('Category: $cat');

                  List<NutritionItem> items = snapshot.data!.docs.where((doc) {
                    final category = doc['category'];
                    return doc['day'] == dayName &&
                        category != null &&
                        category == cat;
                  }).map((doc) {
                    Map<String, dynamic>? data =
                        doc.data() as Map<String, dynamic>?;
                    return NutritionItem(
                      id: doc.id,
                      foodTime:
                          data!['foodTime'] != null ? data['foodTime'] : '',
                      food: data['food'] != null ? data['food'] : '',
                      category:
                          data['category'] != null ? data['category'] : '',
                      day: data['day'] != null ? data['day'] : '',
                      calories: data['calories'] != null ? data['calories'] : 0,
                    );
                  }).toList();

                  List<LinearGradient> gradients = [
                    LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFFE57373),
                        Color(0xFFB71C1C),
                      ],
                    ),
                    LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFF64B5F6),
                        Color(0xFF0D47A1),
                      ],
                    ),
                    LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFFF48FB1),
                        Color(0xFFD81B60),
                      ],
                    ),
                    // Add more gradients as needed
                  ];
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Text(
                          'Today Meals',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            Text(
                              '$dayName',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'RobotoMono',
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(width: 100),
                            Text(
                              ' $cat',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'RobotoMono',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Row(
                          children: items.asMap().entries.map((entry) {
                            int index = entry.key;
                            NutritionItem item = entry.value;
                            List<Widget> foodWidgets = [];
                            item.food.split(' + ').forEach((foodItem) {
                              foodWidgets.add(Text(
                                foodItem,
                                style: const TextStyle(
                                  color: Colors.white, // Set your desired color
                                  fontFamily: 'RobotoMono',
                                  //...
                                ),
                              ));
                            });

                            return Container(
                              child: SizedBox(
                                width: 180,
                                height: 300,
                                child: Container(
                                  child: Card(
                                    margin: EdgeInsets.all(10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient:
                                            gradients[index % gradients.length],
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(40),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.foodTime,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'RobotoMono',
                                                fontSize: 20,
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: foodWidgets,
                                            ),
                                            SizedBox(height: 20),
                                            Row(
                                              children: [
                                                Text(
                                                  '${item.calories} ',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          'RobotoMono' // Set your desired color
                                                      //...
                                                      ),
                                                ),
                                                Text(
                                                  ' kcal',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:50.0, top: 20.0),
                                  child: Text(
                                    "Suggestions",
                                    style: TextStyle(
                                        fontSize: 24, fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                  width: 30,
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Fat foods',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Image.asset(
                                          'assets/images/fats.jpg',
                                          width: 150,
                                          height: 200,
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 20.0,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Protein foods',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Image.asset(
                                          'assets/images/protein.jpg',
                                          width: 150,
                                          height: 200,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Grains foods',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Image.asset(
                                          'assets/images/grains.jpg',
                                          width: 150,
                                          height: 200,
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 20.0,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Fruits & Vegetables foods',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Image.asset(
                                          'assets/images/Fruits_and_vegetables.jpg',
                                          width: 150,
                                          height: 200,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
