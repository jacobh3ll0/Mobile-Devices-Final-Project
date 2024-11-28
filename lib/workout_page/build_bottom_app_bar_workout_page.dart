import 'package:flutter/material.dart';
import 'package:md_final/workout_page/firestore_manager.dart';
import 'package:md_final/workout_page/navigate_to_past_workouts.dart';

import 'create_new_workout_page.dart';

class BuildBottomAppBarWorkoutPage extends StatelessWidget {
  const BuildBottomAppBarWorkoutPage({super.key, required this.firestoreCallback});

  final Function firestoreCallback;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
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
          ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push( //returns a Grade object
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateNewWorkoutPage(),
                    )
                );
                if(result != null) {
                  firestoreCallback(result);
                }
              },
              child: Icon(Icons.add)),

        ],
      ),
    );
  }

}