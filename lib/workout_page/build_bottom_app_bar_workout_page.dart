//flutter packages
import 'package:flutter/material.dart';

//my packages
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
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NavigateToPastWorkouts(),
                )
            );
          }, child: const Text("View Past Workouts")),
          ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push( //returns a WorkoutDataModel object
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateNewWorkoutPage(),
                    )
                );
                if(result != null) { //update ui with new element
                  firestoreCallback(result);
                }
              },
              child: const Icon(Icons.add)),

        ],
      ),
    );
  }
}