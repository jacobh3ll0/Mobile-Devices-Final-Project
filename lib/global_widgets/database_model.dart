import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseModel {
  static final DatabaseModel _instance = DatabaseModel._internal();
  final String _tableName = "userPrefs";
  final String _loggerName = "DataModel";
  late Database _database;

  DatabaseModel._internal();

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


  // Factory constructor
  factory DatabaseModel() {
    return _instance;
  }

  // Getter for database to ensure it is initialized before use
  Future<Database> get database async {
    if (_database == null || !_database.isOpen) {
      await _initDatabase();
    }
    return _database;
  }

  Future<void> _initDatabase() async {
    // Getting the path to store the database file
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, '$_tableName.db'); // Joining the path with the database name

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE $_tableName(id INTEGER PRIMARY KEY, option TEXT, value TEXT)");
      },
    );
    log("database initialized", name: _loggerName);
  }

  // Example of a database method
  Future<void> insertPreference(String option, String value) async {
    final db = await database; // Ensures database is initialized
    await db.insert(
      _tableName,
      {'option': option, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log("Preference inserted: $option = $value", name: _loggerName);
  }

}