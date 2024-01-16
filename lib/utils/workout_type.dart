import 'package:flutter/material.dart';

class WorkoutType extends StatelessWidget {
  final String workoutType;
  final bool isSelected;
  final VoidCallback onTapHead;

  WorkoutType({
    required this.workoutType,
    required this.isSelected,
    required this.onTapHead,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapHead,
      child: Padding(
        padding: const EdgeInsets.only(left: 40.0),
        child: Text(
          workoutType,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.red : Colors.white,
          ),
        ),
      ),
    );
  }
}
