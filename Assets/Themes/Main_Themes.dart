import 'dart:ui';

import 'package:flutter/material.dart';

class MainTheme {
  final Color backgroundColor;
  final Color primaryTextColor;
  final Color accentColor;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;

  MainTheme({
    required this.backgroundColor,
    required this.primaryTextColor,
    required this.accentColor,
    required this.titleStyle,
    required this.bodyStyle,
  });

  // Light theme
  static final light = MainTheme(
    backgroundColor: Colors.white,
    primaryTextColor: Colors.black,
    accentColor: Colors.blue,
    titleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    bodyStyle: TextStyle(fontSize: 16, color: Colors.black54),
  );

  // Dark theme
  static final dark = MainTheme(
    backgroundColor: Colors.black,
    primaryTextColor: Colors.white,
    accentColor: Colors.red,
    titleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    bodyStyle: TextStyle(fontSize: 16, color: Colors.white70),
  );
}
