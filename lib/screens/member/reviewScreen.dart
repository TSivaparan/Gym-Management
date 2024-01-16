import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class GymReview {
  final double rating;
  final String review;

  GymReview({required this.rating, required this.review});
}

class Review extends StatefulWidget {
  final User currentUser;

  Review({required this.currentUser});

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0;
  void _submitReview(GymReview review) async {
    if (review.rating == 0 || review.review.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a rating and review.')),
      );
      return;
    }

    try {
      final reviewsCollection =
          FirebaseFirestore.instance.collection('gymReviews');

      // Retrieve the username from the user collection
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUser.uid);
      final userSnapshot = await userDoc.get();
      if (userSnapshot.exists) {
        final username = userSnapshot.get('username');

        // Save the review with the username in Firestore
        await reviewsCollection.add({
          'rating': review.rating,
          'review': review.review,
          'username': username,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review submitted successfully!')),
        );

        _rating = 0;
        _reviewController.clear();
      } else {
        throw ('User document does not exist');
      }
    } catch (error) {
      print('Error submitting review: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to submit the review. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Rate our app',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white70),
          ),
          SizedBox(height: 30),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 30,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          SizedBox(height: 20),
          Container(
            child: Text(
              'Give Feedback',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70),
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _reviewController,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(width: 3, color: Colors.white70), //<-- SEE HERE
              ),
              labelText: 'Write your reviews here',
              contentPadding: EdgeInsets.only(left: 130),
              labelStyle:
                  TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),

              // alignLabelWithHint: true,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                EdgeInsets.symmetric(vertical: 14.0, horizontal: 44.0),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(
                Color(0xFFB71C1C),
              ),
            ),
            onPressed: () {
              final review = GymReview(
                rating: _rating.toDouble(),
                review: _reviewController.text.trim(),
                // username: widget.currentUser.displayName ?? '',
              );
              _submitReview(review);
            },
            child: Text(
              'Submit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
