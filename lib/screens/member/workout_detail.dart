import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:sample_app/screens/member/time.dart';
import 'package:video_player/video_player.dart';

import '../../utils/sharedPrefencesUtil.dart';

class WorkoutDetail extends StatelessWidget {
  final assetPath, workoutName, instructions, restTime;

  WorkoutDetail(
      {this.assetPath, this.workoutName, this.instructions, this.restTime});
  @override
  Widget build(BuildContext context) {
    final isVideo = assetPath.contains('.mp4?') ? true : false;
    return Scaffold(
      appBar: AppBar(
          // title: Text(workoutName),
          ),
      body: ListView(children: [
        SizedBox(height: 15.0),
        Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Text('Workouts',
              style: TextStyle(
                  fontFamily: 'Varela',
                  fontSize: 42.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70)),
        ),
        SizedBox(height: 15.0),
        Hero(
            tag: assetPath,
            child: Column(
              children: [
                if (isVideo)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Chewie(
                      controller: ChewieController(
                        videoPlayerController:
                            VideoPlayerController.network(assetPath),
                        autoPlay: false,
                        autoInitialize: true,
                        looping: true,
                        allowedScreenSleep: false,
                        showControls: true,
                      ),
                    ),
                  )
                else
                  Image.network(assetPath),
                ListTile(
                  dense: false,
                  // title: Text(workoutName),
                  // subtitle: Text(instructions),
                ),
              ],
            )
            // Image.network(assetPath,
            //     height: 150.0, width: 100.0, fit: BoxFit.contain)
            ),
        SizedBox(height: 10.0),
        Center(
          child: Text(workoutName,
              style: TextStyle(
                  color: Colors.white70, fontFamily: 'Varela', fontSize: 24.0)),
        ),

        SizedBox(height: 20.0),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width - 50.0,
            child: Text(instructions,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Varela',
                  fontSize: 16.0,
                )),
          ),
        ),
        SizedBox(height: 20.0),

        TimerPage(restTime: int.parse(restTime)),
        // ElevatedButton(
        //     onPressed: () {
        //       print(workoutName);
        //       Navigator.push(
        //           context, Mcolor: Color(0xFFB4B8B9)aterialPageRoute(builder: (context) => TimerPage(restTime: int.parse(restTime))));
        //     },
        //     child: Text("Print")),
        // Center(
        //     child: Container(
        //         width: MediaQuery.of(context).size.width - 50.0,
        //         height: 50.0,
        //         decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(25.0),
        //             color: Color(0xff9b1616)),
        //         child: Center(
        //             child: Text(
        //           'Add to List',
        //           style: TextStyle(
        //               fontFamily: 'Varela',
        //               fontSize: 14.0,
        //               fontWeight: FontWeight.bold,
        //               color: Colors.white),
        //         )))),
        // Center(
        //   child: FutureBuilder<String>(
        //     future: SharedPreferencesUtil.getUser(),
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.done &&
        //           snapshot.hasData) {
        //         String username = snapshot.data!;
        //         return Text('username: $username');
        //       } else {
        //         return CircularProgressIndicator();
        //       }
        //     },
        //   ),
        // ),
      ]),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: Color(0xff9b1616),
      //   child: Icon(Icons.sports_gymnastics),
      // ),
    );
  }
}
