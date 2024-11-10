import 'package:flutter/material.dart';
import 'package:md_final/global_widgets/build_bottom_app_bar.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Workout Page")),
      bottomNavigationBar: buildBottomAppBar(context),
    );
  }

}