import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;

import '../../utils/sharedPrefencesUtil.dart';
import 'seeOwnWorkouts.dart';

class AddOwnWorkouts extends StatefulWidget {
  const AddOwnWorkouts({Key? key}) : super(key: key);

  @override
  State<AddOwnWorkouts> createState() => _AddOwnWorkoutsState();
}

class _AddOwnWorkoutsState extends State<AddOwnWorkouts> {
  String? valueChoose;
  TextEditingController _instructionTextController = TextEditingController();
  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _durationController = TextEditingController();
  TextEditingController _restTimeController = TextEditingController();

  FirebaseStorage storage = FirebaseStorage.instance;
  CollectionReference imageCollection =
      FirebaseFirestore.instance.collection('ownWorkouts');

  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  XFile? pickedImageFile;
  File? pickedVideoFile;
  VideoPlayerController? videoController;

  Future<XFile?> _pickImage() async {
    final picker = ImagePicker();
    pickedImageFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    return pickedImageFile;
  }

  Future<File?> _pickVideo() async {
    final picker = ImagePicker();
    pickedVideoFile = File((await picker.pickVideo(
      source: ImageSource.gallery,
    ))!
        .path);
    return pickedVideoFile;
  }

  Future<void> _upload() async {
    String uid = await SharedPreferencesUtil.getUser() ?? '';
    if (pickedImageFile == null && pickedVideoFile == null) {
      // No file picked, show an error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Error',style:TextStyle(
          color: Color(0xff9b1616),
              fontWeight: FontWeight.bold,
              fontSize: 17,
          ),),
          content: const Text('Please pick a file first.',style:TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK',style:TextStyle(
              color: Color(0xff9b1616),
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
              ),),
            ),
          ],
        ),
      );
      return;
    }

    String? imageUrl;
    String? videoUrl;
    String? fileName;

    if (pickedImageFile != null) {
      fileName = path.basename(pickedImageFile!.path);
      File imageFile = File(pickedImageFile!.path);
      String imagePath = 'ownWorkouts/$fileName';

      await storage.ref().child(imagePath).putFile(
            imageFile,
            SettableMetadata(
              customMetadata: {
                'uploaded_by': uid,
              },
            ),
          );

      imageUrl = await storage.ref().child(imagePath).getDownloadURL();
    }

    if (pickedVideoFile != null) {
      fileName = path.basename(pickedVideoFile!.path);
      File videoFile = File(pickedVideoFile!.path);
      String videoPath = 'ownWorkouts/$fileName';

      await storage.ref().child(videoPath).putFile(
            videoFile,
            SettableMetadata(
              customMetadata: {
                'uploaded_by': uid,
              },
            ),
          );

      videoUrl = await storage.ref().child(videoPath).getDownloadURL();
    }

    try {
      // Show confirmation message
      bool confirmUpload = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmation' ,style:TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),),
          content: const Text('Do you want to upload the file?',style:TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes',style:TextStyle(
                color: Color(0xff9b1616),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No',style:TextStyle(
              color: Color(0xff9b1616),
              fontWeight: FontWeight.bold,
              fontSize: 17,
              ),),
            ),
          ],
        ),
      );

      if (confirmUpload == true) {
        DocumentReference userDoc = usersCollection.doc(uid);
        DocumentReference ownWorkoutDoc =
            userDoc.collection('ownWorkout').doc(fileName);
        await ownWorkoutDoc.set({
          if (imageUrl != null) 'url': imageUrl,
          if (videoUrl != null) 'url': videoUrl,
          'fileName': fileName,
          'date': DateTime.now(),
          'workoutName': _nameTextController.text,
          'category': _categoryController.text,
          'duration': _durationController.text,
          'restTime': _restTimeController.text,
          'instructions': _instructionTextController.text,
        });

        setState(() {});
      }
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  List<String> listItem = ["chest", "abs", "shoulder", "triceps"];

  @override
  void initState() {
    super.initState();
    videoController = VideoPlayerController.network('');
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.only(left: 55, right: 55, top:10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.05),
              TextFormField(
                controller: _nameTextController,
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.white70),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 50.0, top:10.0),
                        child: const Text(
                          "Category",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),

                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      DropdownButton(
                        hint: const Text("Select Category"),
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 15,
                        isExpanded: false,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        value: valueChoose,
                        onChanged: (value) {
                          setState(() {
                            valueChoose = value as String?;
                            _categoryController.text = valueChoose ?? '';
                          });
                        },
                        items: listItem.map((valueItem) {
                          return DropdownMenuItem(
                            value: valueItem,
                            child: Text(valueItem),
                          );
                        }).toList(),
                      ),
                    ],
                  )
                ],
              ),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: "Workout duration(seconds)",
                  labelStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70,),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.white70),
                  ),
                ),
              ),
              TextFormField(
                controller: _restTimeController,
                decoration: InputDecoration(
                  labelText: "Rest time(seconds)",
                  labelStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70,),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.white70),
                  ),
                ),
              ),
              TextFormField(
                controller: _instructionTextController,
                decoration: InputDecoration(
                  labelText: "Give the Instruction",
                  labelStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70,),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.white70),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white38,
                    ),
                    onPressed: () async {
                      await _pickImage();
                    },
                    icon: const Icon(Icons.photo_library_sharp),
                    label: const Text('Pick Picture'),
                  ),
                  Column(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white38,
                        ),
                        onPressed: () async {
                          await _pickVideo();
                          videoController =
                              VideoPlayerController.file(pickedVideoFile!)
                                ..initialize().then((_) {
                                  setState(() {});
                                });
                        },
                        icon: const Icon(Icons.video_library_sharp),
                        label: const Text('Pick Video'),
                      ),
                      // if (videoController != null &&
                      //     videoController!.value.isInitialized)
                      //   AspectRatio(
                      //     aspectRatio: videoController!.value.aspectRatio,
                      //     child: VideoPlayer(videoController!),
                      //   ),
                    ],
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff9b1616),
                    ),
                    onPressed: () {
                      _upload();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white38,
                  ),
                  child: Text("See own workouts"),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SeeOwnWorkouts()));
                    // });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
