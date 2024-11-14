// -- Flutter/dart packages -- //

import 'dart:developer';
import 'package:flutter/material.dart';

// -- our packages -- //
import 'package:md_final/global_widgets/build_bottom_app_bar.dart';
import 'global_widgets/user_prefs_database_model.dart';

// page routes
import 'package:md_final/HomePage/home_page.dart';
import 'package:md_final/nutrition_page/nutrition_page.dart';
import 'package:md_final/profile_page/profile_page.dart';
import 'package:md_final/social_page/social_page.dart';
import 'package:md_final/workout_page/workout_page.dart';

// -----------------  //


// function to trigger build when the app is run
void main() {
  WidgetsFlutterBinding.ensureInitialized(); //do not remove

  DatabaseModel userPrefs = DatabaseModel();

  runApp(MaterialApp(
    initialRoute: '/home',
    routes: {
      '/home': (context) => const HomeNavigator(),
      '/nutrition': (context) => const NutritionPage(),
      '/profile': (context) => const ProfilePage(),
      '/workout': (context) => const WorkoutPage(),
      '/social': (context) => const SocialPage(),
    },
    theme: DatabaseModel.getThemeData(),
    // darkTheme: _defaultTheme(true),
    // darkTheme: _darkTheme(),
    home: HomeNavigator(),
  ));
}


class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _currentPageIndex = 0;

  //list of pages
  final List<Widget> _pages = [
    HomePage(),
    NutritionPage(),
    WorkoutPage(),
    SocialPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BuildBottomNavigationBar(onTap: _onNavigationButtonTap, getIndex: _getCurrentSelectedIndex),
      body: IndexedStack(
        index: _currentPageIndex,
        children: _pages,
      ),
    );
  }

  void _onNavigationButtonTap(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  int _getCurrentSelectedIndex() {
    return _currentPageIndex;
  }

}