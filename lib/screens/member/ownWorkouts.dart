import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../utils/sharedPrefencesUtil.dart';
import 'package:provider/provider.dart';

import 'workout_detail.dart';

class OwnWorkouts extends StatelessWidget {
  final category;

  OwnWorkouts({this.category});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: ListView(
        children: <Widget>[
          SizedBox(height: 15.0),
          Container(
            padding: EdgeInsets.all(15.0),
            width: 200.0,
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
                    crossAxisCount: 2,
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

    String uid = await SharedPreferencesUtil.getUser() ?? '';

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ownWorkout')
        .get();

    for (final DocumentSnapshot doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      mediaFiles.add({
        "url": data['url'] ?? '',
        "category": data['category'] ?? '',
        "fileName": data['fileName'] ?? '',
        "date": data['date'] ?? '',
        "workoutName": data['workoutName'] ?? '',
        "instructions": data['instructions'] ?? 'No instructions',
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
                          autoInitialize: false,
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
