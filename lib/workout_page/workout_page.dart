import 'package:flutter/material.dart';
import 'package:md_final/workout_page/firestore_manager.dart';
import 'package:md_final/workout_page/workout_data_model.dart';


class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {

    FirestoreManager manager = FirestoreManager();
    manager.storeUserData(WorkoutDataModel(workoutName: "Dumbbell fly", muscleGroup: "chest", weight: 15, reps: 5).toMap());



    return Scaffold(
      appBar: AppBar(title: Text("Workout Page"), automaticallyImplyLeading: false),
    );
  }



}