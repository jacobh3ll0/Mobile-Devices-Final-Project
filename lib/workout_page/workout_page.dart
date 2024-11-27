import 'package:flutter/material.dart';
import 'package:md_final/workout_page/active_workout_firebase_display.dart';
import 'package:md_final/workout_page/build_bottom_app_bar_workout_page.dart';
import 'package:md_final/workout_page/create_new_workout_page.dart';
import 'package:md_final/workout_page/firestore_manager.dart';
import 'package:md_final/workout_page/workout_data_model.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {

  late FirestoreManager manager = FirestoreManager();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FirebaseFetcher(manager: manager),
      bottomNavigationBar: BuildBottomAppBarWorkoutPage(firestoreCallback: _updateFirebase),
    );

  }

  void _updateFirebase(var result) {
    setState(() {
      manager.storeUserData(result.toMap());
    });
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context) // show snack bar
        .showSnackBar(SnackBar(content: Text(message)));
  }
}