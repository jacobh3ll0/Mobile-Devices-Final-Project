import 'dart:async';
import 'dart:developer';
import 'package:md_final/global_widgets/user_options.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseModel {
  static final DatabaseModel _instance = DatabaseModel._internal();
  final String _tableName = "userPrefs";
  final String _loggerName = "DataModel";
  late final Future<Database> _databaseFuture;

  DatabaseModel._internal() {
    _databaseFuture = _initDatabase();
  }

  factory DatabaseModel() {
    return _instance;
  }

  //getter
  Future<Database> get database => _databaseFuture;

  // Initialize the database
  Future<Database> _initDatabase() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, '$_tableName.db');

    // Opening db
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE $_tableName(id INTEGER PRIMARY KEY, option TEXT, value TEXT)",
        );
      },
    );
    log("Database initialized", name: _loggerName);
    return db;
  }

  Future<List<UserOptions>> getUserOptionsAsLists() async {

    // ensure database is initialized
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    List<UserOptions> optionsList = [];
    for (int i = 0; i < maps.length; i++) {
      optionsList.add(UserOptions.fromMap(maps[i]));
    }

    for (int i = 0; i < maps.length; i++) {
      log(optionsList[i].toString(), name: _loggerName);
    }

    return optionsList;
  }

  Future<Map<String, String>> getUserOptionsAsMaps() async {

    // ensure database is initialized
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    Map<String, String> optionsMaps = {};
    for (int i = 0; i < maps.length; i++) {
      // optionsMaps.add(UserOptions.fromMap(maps[i]));
      UserOptions temp = UserOptions.fromMap(maps[i]);
      if(!optionsMaps.containsKey(temp.option)) {
        optionsMaps[temp.option] = temp.value;
      } else {
        log("Duplicate entry for user options exists in database, ignoring: [$temp]", name: _loggerName);
      }
    }

    for (int i = 0; i < maps.length; i++) {
      log(maps.toString(), name: _loggerName);
    }

    return optionsMaps;
  }

  Future<void> insertUserOption(String option, String value) async {
    final db = await database; // Ensures database is initialized
    await db.insert(
      _tableName,
      {'option': option, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log("Preference inserted: $option = $value", name: _loggerName);
  }

  Future<void> editUserOption(String option, String value) async {

    final db = await database; // Ensures database is initialized

    // Fetch the current record to get the ID
    final List<Map<String, dynamic>> records = await db.query(
      _tableName,
      where: "option = ?",
      whereArgs: [option],
      limit: 1, // limit to one record
    );

    if (records.isEmpty) {
      log("Option $option does not exist in the database.", name: _loggerName);
      return;
    }

    // get ID from table
    final int id = records.first['id'];

    // Create the updated UserOptions object
    UserOptions userOpts = UserOptions(option: option, value: value, id: id);

    await db.update(
      _tableName,  // Table name
      userOpts.toMap(),  //convert to map
      where: "id = ?",
      whereArgs: [userOpts.id],  // Argument for WHERE clause
    );
    log("updated: $option = $value", name: _loggerName);
  }

  Future<void> deleteUserOption(int id) async {
    final db = await database; // Ensures database is initialized
    await db.delete(
      _tableName, // Table name
      where: 'id = ?',
      whereArgs: [id],
    );
    log("deleted, id: $id", name: _loggerName);
  }
}
