import 'package:flutter/material.dart';
import '../../utils/imageTile.dart';
import '../../utils/workout_type.dart';
import 'workout_page.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late ScrollController _scrollController;
  int selectedWorkoutIndex = 0; // Track the selected workout type index

  // List of workout types
  final List<dynamic> workoutType = [
    ['Chest', true],
    ['Abs', false],
    ['Shoulders', false],
  ];

  void workoutTypeSelected(int index) {
    setState(() {
      // Update the selected workout type index
      selectedWorkoutIndex = index;
      // Set the selected workout type to true and others to false
      for (int i = 0; i < workoutType.length; i++) {
        workoutType[i][1] = (i == index);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize the ScrollController
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    // Dispose the ScrollController when not needed
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Text(
              'Workout Page',
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Image.asset("assets/images/workout.jpg"),
              color: Colors.black,
              height: 150,
            ),
          ),
          // Horizontal list view
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: workoutType.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    workoutTypeSelected(index);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      // color: workoutType[index][1]
                      //     ? Colors.red
                      //     : Colors.transparent,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      workoutType[index][0],
                      style: TextStyle(
                        color:
                            workoutType[index][1] ? Colors.red : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              controller: _scrollController,
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController, // Use the same controller
              children: [
                if (selectedWorkoutIndex == 0) // Show Chest workouts
                  ImageTile(
                    workoutImgPath: 'assets/images/chest.jpg',
                    workoutName: 'Chest',
                  ),
                if (selectedWorkoutIndex == 1) // Show Abs workouts
                  ImageTile(
                    workoutImgPath: 'assets/images/abs.jpg',
                    workoutName: 'Abs',
                  ),
                if (selectedWorkoutIndex == 2) // Show Shoulder workouts
                  ImageTile(
                    workoutImgPath: 'assets/images/shoulder.png',
                    workoutName: 'Shoulder',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
