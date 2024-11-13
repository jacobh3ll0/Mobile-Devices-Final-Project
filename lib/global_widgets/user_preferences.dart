import 'package:flutter/material.dart';

class UserPreferences {

  static late ThemeData theme;

  UserPreferences() {

    // to use these themes do Theme.of(context).primaryColor
    ColorScheme pallete = ColorScheme.fromSwatch(
      primarySwatch: Colors.purple,
      accentColor: Colors.blue,
      backgroundColor: Colors.grey,
      brightness: Brightness.light,
    );

    theme = ThemeData(
      useMaterial3: true,
      colorScheme: pallete,
      canvasColor: Colors.grey, // controls colour of navigation bar
    );
  }

  static getThemeData() {
    return theme;
  }

}


// create a database on disk to store user preferences
// format of the table
// | Option       | Value       |
// | String       | String      |
// | darkMode     | false/true  |
