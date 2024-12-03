import 'package:flutter/material.dart';
import 'package:md_final/workout_page/active_workout_firebase_display.dart';
import 'package:md_final/workout_page/build_bottom_app_bar_workout_page.dart';
import 'package:md_final/workout_page/firestore_manager.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {

  //initialize the FirestoreManager specifically for workout data
  late FirestoreManager manager = FirestoreManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Workouts")),
      body: FirebaseFetcher(manager: manager),
      bottomNavigationBar: BuildBottomAppBarWorkoutPage(firestoreCallback: _updateFirebase),
    );
  }

  //callback for the button "+" on the bottom of the page
  void _updateFirebase(var result) {
    setState(() {
      manager.storeUserData(result.toMap());
    });
  }

}