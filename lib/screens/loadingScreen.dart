import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(), // Loading spinner
              SizedBox(height: 16),
              Text("Loading..."), // Optional loading text
            ],
          ),
        ),
      ),
    );
  }
}
