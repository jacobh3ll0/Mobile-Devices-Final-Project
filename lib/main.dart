// -- Flutter/dart packages -- //

import 'dart:developer';
import 'package:flutter/material.dart';

// -- our packages -- //
import 'package:md_final/global_widgets/build_bottom_app_bar.dart';
import 'package:md_final/global_widgets/theme_related/theme_manager.dart';
import 'global_widgets/database_model.dart';
import 'global_widgets/database_model_user_prefs.dart';

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

  //init database, this will stay open, you can access it by creating a variable like below
  //basically if it is already open DatabaseModel() will return an instance of it
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
    theme: ThemeManager.getThemeData(),
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