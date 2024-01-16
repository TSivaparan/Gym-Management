import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  Future<List<Map<String, dynamic>>> _loadReviews() async {
    List<Map<String, dynamic>> reviews = [];

    final QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('gymReviews').get();

    for (final DocumentSnapshot doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      reviews.add({
        "rating": data['rating'].toString()  ?? '',
        "review": data['review'] ?? '',
        "username": data['username'] ?? '',
      });
    }

    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body: Column(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadReviews(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                final reviews = snapshot.data ?? [];

                return Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Adjust the number of columns as needed
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];

                      return Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Rating: ${review['rating']}'),
                            Text('Review: ${review['review']}'),
                            Text('Username: ${review['username']}'),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
          Container(
            width: 100,
            height: 100,
            color: Colors.blue,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("hello"),
            ),
          ),
        ],
      ),
    );
  }
}
