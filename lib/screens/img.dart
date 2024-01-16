import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class UploadImg extends StatefulWidget {
  const UploadImg({Key? key}) : super(key: key);

  @override
  State<UploadImg> createState() => _UploadImgState();
}

class _UploadImgState extends State<UploadImg> {
  String? valueChoose;
  TextEditingController _instructionTextController = TextEditingController();
  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();

  FirebaseStorage storage = FirebaseStorage.instance;
  CollectionReference imageCollection =
      FirebaseFirestore.instance.collection('img');

  XFile? pickedImageFile;

  Future<XFile?> _pickImage() async {
    final picker = ImagePicker();
    pickedImageFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    return pickedImageFile;
  }

  Future<void> _upload() async {
    if (pickedImageFile == null) {
      // No file picked, show an error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please pick an image first.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    String? imageUrl;
    String? fileName;

    fileName = path.basename(pickedImageFile!.path);
    File imageFile = File(pickedImageFile!.path);

    // Uploading the selected image with some custom metadata
    await storage.ref(fileName).putFile(
          imageFile,
          SettableMetadata(
            customMetadata: {
              'uploaded_by': 'coach..',
            },
          ),
        );

    imageUrl = await storage.ref(fileName).getDownloadURL();

    try {
      // Show confirmation message
      bool confirmUpload = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Do you want to upload the file?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
          ],
        ),
      );

      if (confirmUpload == true) {
        await imageCollection.doc(fileName).set({
          if (imageUrl != null) 'url': imageUrl,
          'fileName': fileName,
          'date': DateTime.now(),
          'uploaded_by': 'Coach',
          'category': _categoryController.text,
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

  List<String> listItem = ["Chest", "Abs", "Shoulder", "Triceps"];

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form"),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 55, right: 55),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: const Text(
                        "Category",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    DropdownButton(
                      hint: const Text("Select Category"),
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 20,
                      isExpanded: false,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
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
              controller: _instructionTextController,
              decoration: InputDecoration(
                labelText: "Give the Instruction",
                labelStyle:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await _pickImage();
                  },
                  icon: const Icon(Icons.photo_library_sharp),
                  label: const Text('Pick Picture'),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    _upload();
                  },
                  child: const Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
