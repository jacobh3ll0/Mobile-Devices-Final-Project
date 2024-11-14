import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'user_options.dart';

String _loggerName = "DataModel";

class DatabaseModel {
  static late Database database;
  final String _tableName = "userPrefs";

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

  //wrapper / simple functions
  static insertOption(String option, String value) {
    _insertOption(UserOptions(option: option, value: value));
  }


  // database functions ----------

  DatabaseModel() {
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    // Getting the path to store the database file
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, '$_tableName.db'); // Joining the path with the database name

    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE $_tableName(id INTEGER PRIMARY KEY, option TEXT, value TEXT)");
      },
    );
    log("database initialized", name: _loggerName);
  }

  Future<void> _insertOption(UserOptions option) async {
    log("inserting option: $option", name: _loggerName);
    await database.insert(
      _tableName, //table name
      option.toMap(),  // convert to map
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _editOption(UserOptions option) async {
    log("updating option: $option", name: _loggerName);
    await database.update(
      _tableName,  // Table name
      option.toMap(),  //convert to map
      where: "id = ?",
      whereArgs: [option.id],  // Argument for WHERE clause
    );
  }

  // Future<void> deleteGrade(int id) async {
  //   log("deleting grade");
  //   await database.delete(
  //     'grades', // Table name
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  Future<List<UserOptions>> getOptions() async {
    log("querying database", name: _loggerName);
    final List<Map<String, dynamic>> maps = await database.query(_tableName);

    List<UserOptions> optionsList = [];
    for (int i = 0; i < maps.length; i++) {
      optionsList.add(UserOptions.fromMap(maps[i]));
    }

    for (int i = 0; i < maps.length; i++) {
      log(optionsList[i].toString());
    }

    log("data obtained from database");
    return optionsList;

  }




}

