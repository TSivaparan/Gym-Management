import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  final String workoutImgPath;
  final String workoutName;

  ImageTile({required this.workoutImgPath, required this.workoutName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(12),
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image container
            Expanded(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(workoutImgPath)),
            ),

            // image container
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workoutName,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "Chest workout",
                    style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "data",
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6)),
                    child: Icon(
                      Icons.watch_later,
                      color: Colors.white,
                    ),
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