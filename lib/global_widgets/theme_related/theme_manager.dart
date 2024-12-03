import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:md_final/global_widgets/database_model.dart';


class ThemeManager {
    static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // colour information for main theme
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.red,
      accentColor: Colors.orangeAccent,
      backgroundColor: Colors.white,
      brightness: Brightness.light,
    ),

    canvasColor: Colors.white24, // controls colour of navigation bar
  );

    static ThemeData darkTheme = ThemeData(
      useMaterial3: true,

      // ChatGPT generated dark theme because I suck at UI
      // Color scheme for the dark theme
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.deepOrange, // Base color for primary UI elements
        accentColor: Colors.deepOrangeAccent, // Accent color for highlights
        backgroundColor: Colors.black, // Background color for screens
        brightness: Brightness.dark,
        errorColor: Colors.white

        // Ensures the theme is dark
      ),


      // Additional properties for dark theme
      scaffoldBackgroundColor: const Color(0xFF121212), // Typical dark mode background
      canvasColor: const Color(0xFF1F1F1F), // Navigation bar or drawer background
      cardColor: const Color(0xFF1E1E1E), // Background for cards
      dividerColor: Colors.grey.shade800, // Divider lines in lists or UI sections
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white), // Main text color
        bodyMedium: TextStyle(color: Colors.grey), // Secondary text color
      ),

    );


  // theme functions

  static Future<ThemeData> getThemeData() async {
    DatabaseModel database = DatabaseModel();

    Map<String, String> maps = await database.getUserOptionsAsMaps(); //need to make function to do this
    if(maps["darkmode"] == "true") {
      log("returning dark theme", name: "ThemeManager");
      return darkTheme;
    }
    log("returning light theme", name: "ThemeManager");
    return lightTheme;
  }

  static Future<void> initUserOptions() async {
    DatabaseModel database = DatabaseModel();
    Map<String, String> maps = await database.getUserOptionsAsMaps();
    if(!maps.containsKey("darkmode")) {
      database.insertUserOption("darkmode", "false");
    }
  }

  static getLightTheme() {
    return lightTheme;
  }


}