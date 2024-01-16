import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PackageDetailsPage extends StatefulWidget {
  @override
  _PackageDetailsPageState createState() => _PackageDetailsPageState();
}

class _PackageDetailsPageState extends State<PackageDetailsPage> {
  String? selectedCategory;
  Future<List<Map<String, dynamic>>> _loadMedia() async {
    List<Map<String, dynamic>> mediaFiles = [];

    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('packages').get();

    for (final DocumentSnapshot doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      mediaFiles.add({
        "url": data['url'] ?? '',
        "packageName": data['packageName'] ?? '',
        "description": data['description'] ?? '',
        "price": data['price'] ?? '',
        "duration": data['duration'] ?? '',
      });
    }

    return mediaFiles;
  }

  Future<void> addPackageToFirestore(String packageName, String userUID, String s) async {
    final CollectionReference usersRef =
        FirebaseFirestore.instance.collection('users');

    final DocumentSnapshot userDoc = await usersRef.doc(userUID).get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      if (userData['PackageName'] == null) {
        await usersRef.doc(userUID).update({
          'PackageName': packageName,
          'SelectedCategory' :selectedCategory,
        });
        print('Package added successfully to the user document!');
      } else {
        print('Package already added for this user.');
      }
    } else {
      print('User not found.');
    }
  }

  String getCurrentUserUID() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      return user.uid;
    } else {
      return '';
    }
  }

  Widget build(BuildContext context) {

    String currentUserUID = getCurrentUserUID();
    return Scaffold(
      appBar: AppBar(
        title: Text('Package Details'),
        backgroundColor: Colors.white12,
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

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Image.network(media['url']),
                              Container(
                                color: Colors.black54,
                                child: ListTile(
                                  dense: false,
                                  title: Text(media['packageName'],
                                      style: TextStyle(color: Colors.white70)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Text('Description: ${media['description']}'),
                                      SizedBox(height: 10),
                                      Text('Price: Rs  ${media['price']} .00'),
                                      SizedBox(height: 10),
                                      Text('Duration: ${media['duration']} Month'),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Radio<String>(
                                    activeColor:Colors.white70,
                                    value: 'Weight Gain',
                                    groupValue: selectedCategory,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCategory = value;
                                      });
                                    },
                                  ),
                                  Text('Weight Gain'),
                                  Radio<String>(
                                    activeColor:Colors.white70,
                                    value: 'Weight Loss',
                                    groupValue: selectedCategory,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCategory = value;
                                      });
                                    },
                                  ),
                                  Text('Weight Loss'),
                                ],
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  if (selectedCategory != null) {
                                    addPackageToFirestore(
                                        media['packageName'],
                                        currentUserUID,
                                        selectedCategory!);
                                  }
                                },
                                child: Text('Add Package'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
