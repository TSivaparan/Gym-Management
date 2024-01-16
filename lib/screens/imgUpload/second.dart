import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class Second extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Retrieval',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoScreen(
        videoUrl:
            'https://firebasestorage.googleapis.com/v0/b/signin-sample-49c02.appspot.com/o/10%20Best%20Tricep%20Exercises%20For%20Bigger%20Arms%20_%20TRICEPS%20WORKOUT.mp4?alt=media&token=f50aecc2-1bc9-4305-b8fd-b19aa15b4694', // Replace with your actual video URL
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  final String videoUrl;

  VideoScreen({required this.videoUrl});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late Future<http.Response> _videoFuture;
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoFuture = fetchVideo(widget.videoUrl);
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  Future<http.Response> fetchVideo(String videoUrl) {
    return http.get(Uri.parse(videoUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video'),
      ),
      body: FutureBuilder<http.Response>(
        future: _videoFuture,
        builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading video'));
          } else {
            if (snapshot.data?.statusCode == 200) {
              return Chewie(controller: _chewieController);
            } else {
              return Center(child: Text('Failed to load video'));
            }
          }
        },
      ),
    );
  }
}
