import 'package:flutter/material.dart';
import 'package:md_final/workout_page/navigate_to_past_workouts.dart';

class BuildBottomAppBarWorkoutPage extends StatelessWidget {
  const BuildBottomAppBarWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      // color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(onPressed: () {
            Navigator.push( //returns a Grade object
                context,
                MaterialPageRoute(
                  builder: (context) => NavigateToPastWorkouts(),
                )
            );
          }, child: Text("View Past Workouts")),
          ElevatedButton(onPressed: () {}, child: Icon(Icons.add)),

        ],
      ),
    );
  }

}