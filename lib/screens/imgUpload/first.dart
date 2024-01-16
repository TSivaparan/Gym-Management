import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

import 'second.dart';
import 'uploadform.dart';
import 'video.dart';

class ImgUp extends StatefulWidget {
  const ImgUp({Key? key}) : super(key: key);

  @override
  State<ImgUp> createState() => _ImgUpState();
}

class _ImgUpState extends State<ImgUp> {
  FirebaseStorage storage = FirebaseStorage.instance;
  CollectionReference imageCollection =
      FirebaseFirestore.instance.collection('workouts');
  late String url;

  Future<List<Map<String, dynamic>>> _loadMedia() async {
    List<Map<String, dynamic>> mediaFiles = [];

    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('workouts').get();

    for (final DocumentSnapshot doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      mediaFiles.add({
        "url": data['url'] ?? '',
        "fileName": data['fileName'] ?? '',
        "date": data['date'] ?? '',
        "uploaded_by": data['uploaded_by'] ?? 'Nobody',
        "instructions": data['instructions'] ?? 'No instructions',
      });
    }

    return mediaFiles;
  }

  // Delete the selected image/video
  // This function is called when a trash icon is pressed
  Future<void> _delete(String ref) async {
    await storage.ref().child('workouts/$ref').delete();
    await imageCollection.doc(ref).delete();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JK'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: _loadMedia(),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> media =
                            snapshot.data![index];
                        // Check if the media is a video

                        final isVideo =
                            media['url'].contains('.mp4?') ? true : false;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              if (isVideo)
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Chewie(
                                    controller: ChewieController(
                                      videoPlayerController:
                                          VideoPlayerController.network(
                                              media['url']),
                                      autoPlay: false,
                                      autoInitialize: true,
                                      looping: true,
                                      allowedScreenSleep: false,
                                      showControls: true,
                                    ),
                                  ),
                                )
                              else
                                Image.network(media['url']),
                              ListTile(
                                dense: false,
                                title: Text(media['fileName']),
                                subtitle: Text(media['instructions']),
                                trailing: IconButton(
                                  onPressed: () {
                                    if (media != null &&
                                        media.containsKey('fileName')) {
                                      _delete(media['fileName']);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Second()),
                );
              },
              child: const Text("Show Images"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadForm()),
                );
              },
              child: const Text("upload workouts"),
            ),
          ],
        ),
      ),
    );
  }
}
