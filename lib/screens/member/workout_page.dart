import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../utils/sharedPrefencesUtil.dart';
import 'package:provider/provider.dart';

import 'workout_detail.dart';

class Workouts extends StatelessWidget {
  final category;
  final uid;

  Workouts({this.category, this.uid});

  bool isChecked = false;

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  Future<void> checkWorkouts(
      BuildContext context, String uid, bool checked, String workout) async {
    String tik;
    String currentDate = DateTime.now().toString().split(' ')[0];

    if (checked) {
      tik = "checked";
      try {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(uid);
        CollectionReference workoutHistoryRef =
            userRef.collection('workout_history');

        DocumentSnapshot workoutHistorySnapshot =
            await workoutHistoryRef.doc(currentDate).get();

        if (workoutHistorySnapshot.exists) {
          // If the document for the current date exists, update the exercises array
          await workoutHistoryRef.doc(currentDate).update({
            'exercises': FieldValue.arrayUnion([workout]),
          });
        } else {
          // If the document for the current date doesn't exist, create a new document
          await workoutHistoryRef.doc(currentDate).set({
            'date': currentDate,
            'exercises': [workout],
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$workout added to the history')),
        );

        print('Workout added successfully!');
      } catch (e) {
        print('Error adding workout: $e');
      }
    } else {
      tik = "not checked";
    }

    print(uid);
    print(workout);
    print(tik);
    print(uid + currentDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: ListView(
        children: <Widget>[
          SizedBox(height: 15.0),
          Container(
            padding: EdgeInsets.all(15.0),
            width: MediaQuery.of(context).size.width - 80.0,
            height: MediaQuery.of(context).size.height - 50.0,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadMedia(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading data.'),
                  );
                } else {
                  final mediaFiles = snapshot.data ?? [];
                  return GridView.count(
                    crossAxisCount: 1,
                    primary: false,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.8,
                    children: buildCardList(context, mediaFiles),
                  );
                }
              },
            ),
          ),
          SizedBox(height: 15.0),
        ],
      ),
    );
  }

  FirebaseStorage storage = FirebaseStorage.instance;
  Future<List<Map<String, dynamic>>> _loadMedia() async {
    List<Map<String, dynamic>> mediaFiles = [];

    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('workouts').get();

    for (final DocumentSnapshot doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      mediaFiles.add({
        "url": data['url'] ?? '',
        "category": data['category'] ?? '',
        "fileName": data['fileName'] ?? '',
        "date": data['date'] ?? '',
        "workoutName": data['workoutName'] ?? '',
        "instructions": data['instructions'] ?? 'No instructions',
        "restTime": data['restTime'] ?? 'No restTime',
      });
    }

    return mediaFiles;
  }

  List<Widget> buildCardList(
      BuildContext context, List<Map<String, dynamic>> mediaFiles) {
    List<Widget> cardList = [];

    for (final Map<String, dynamic> media in mediaFiles) {
      // Check if the category matches the selected category
      print(media['category']);
      if (category == media['category']) {
        cardList.add(_buildCard(
          media['workoutName'],
          media['url'],
          media['category'],
          media['instructions'],
          media['restTime'],
          false,
          context,
          media[
              'fileName'], // You may want to use a unique identifier for the heroTag
        ));
      }
    }

    return cardList;
  }

  Widget _buildCard(
    String name,
    String imgPath,
    String cat,
    String instruction,
    String restTime,
    bool isFavourite,
    context,
    String heroTag,
  ) {
    final isVideo = imgPath.contains('.mp4?') ? true : false;

    return Padding(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutDetail(
                assetPath: imgPath,
                workoutName: name,
                instructions: instruction,
                restTime: restTime,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [],
            color: Colors.black,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ChangeNotifierProvider(
                      create: (_) => CheckboxProvider(),
                      child: Consumer<CheckboxProvider>(
                        builder: (context, checkboxProvider, _) => Checkbox(
                          value: checkboxProvider.isChecked,
                          onChanged: (value) async {
                            checkboxProvider.isChecked = value ?? true;
                            String uid =
                                await SharedPreferencesUtil.getUser() ?? '';
                            checkWorkouts(context, uid as String,
                                checkboxProvider.isChecked, name);
                          },
                          activeColor: Color(0xff9b1616),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Hero(
                tag: heroTag,
                child: Container(
                  height: 250.0,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: AspectRatio(
                      aspectRatio:
                          16 / 9, // Change this ratio based on your requirement
                      child: isVideo
                          ? Chewie(
                              controller: ChewieController(
                                videoPlayerController:
                                    VideoPlayerController.network(imgPath),
                                autoPlay: false,
                                autoInitialize: true,
                                looping: false,
                                allowedScreenSleep: false,
                                showControls: true,
                              ),
                            )
                          : Image.network(
                              imgPath,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
              ),
              ListTile(
                dense: false,
                title: Text(name),
                subtitle: Text(cat),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckboxProvider with ChangeNotifier {
  bool _isChecked = false;

  bool get isChecked => _isChecked;

  set isChecked(bool value) {
    _isChecked = value;
    notifyListeners();
  }
}
