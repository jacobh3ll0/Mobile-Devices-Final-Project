import 'dart:developer';

import 'package:flutter/material.dart';


// -- our packages -- //

// page routes
import 'package:md_final/nutrition_page/nutrition_page.dart';
import 'package:md_final/profile_page/profile_page.dart';
import 'package:md_final/social_page/social_page.dart';
import 'workout_page/workout_page.dart';

// helper functions
import 'package:md_final/global_widgets/build_bottom_app_bar.dart';

// -----------------  //




// function to trigger build when the app is run
void main() {
  runApp(MaterialApp(
    initialRoute: '/home',
    routes: {
      '/home': (context) => const HomePage(),
      '/nutrition': (context) => const NutritionPage(),
      '/profile': (context) => const ProfilePage(),
      '/workout': (context) => const WorkoutPage(),
      '/social': (context) => const SocialPage(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildTopAppBar(),
      bottomNavigationBar: buildBottomAppBar(context),
      body: Text("hello!")
    );
  }

  AppBar _buildTopAppBar() {
    return AppBar(
      title: const Text('Workout App'),
      backgroundColor: Colors.green,
    );
  }

}