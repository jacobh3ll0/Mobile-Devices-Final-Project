import 'package:flutter/material.dart';


class ThemeManager {
    static ThemeData theme = ThemeData(
    useMaterial3: true,

    // colour information for main theme
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.purple,
      accentColor: Colors.blue,
      backgroundColor: Colors.grey,
      brightness: Brightness.light,
    ),

    canvasColor: Colors.grey, // controls colour of navigation bar
  );

  // theme functions

  static getThemeData() {
    return theme;
  }


}