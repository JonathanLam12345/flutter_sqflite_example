import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  // he name of our database
  static final _databaseName = "MyDatabase.db";

  // Database version
  static final _databaseVersion = 1;

  // The name of the database table
  static final table = 'my_table';

  // The database table has 3 columns with the following names:
  static final columnId = '_id';
  static final columnName = 'name';
  static final columnAge = 'age';

  // Make this a singleton class because we only want one instance of this class.
  DatabaseHelper._privateConstructor();

  // Create an instance of the class.
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static  Database? _database;

  //Get the database
  Future<Database?> get database async {
    // The database is accessed for the first time and therefore is null.
    if (_database == null) {
      _database = await _initDatabase(); // Let's create a new database.
    } else {
      return _database;
    }
    return _database;
  }

  // Since the database does not exist, let's create a new database.
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    // openDatabase(path of where to store the db,
    // database version,
    // onCreate(db, version): What to do once the database has been created, we want to create a table.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    // columnId is an int and primary key
    // columnName is a string and cannot be null
    // columnAge is an int and cannot be null

    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,  
            $columnName TEXT NOT NULL,
            $columnAge INTEGER NOT NULL
          )
          ''');
  }

  // Helper methods

// insert, update, delete,
// Query will return a list of map.
  //For example: {"id:" 12, "name":"Jonathan"}

  //When we insert values into the table, it must be passed as a type of "map"

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the inserted row.
  // Return the unique primary key that was created
  Future<int?> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db?.insert(table, row);
  }

  // We are assuming here that the id column in the map is set.
  // The other column values will be used to update the row.
  Future<int?> update(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row[columnId];
    return await db?.update(table, row, where: '$columnId = ?', whereArgs: [id]);
    // return await db.update(table, row, where: '$columnId = ? $columnName = ?', whereArgs: [0, 'Jonathan']);
  }

  // Deletes the row specified by the id.
  // The number of affected rows is returned.
  // This should be 1 as long as the row exists.
  Future<int?> delete(int id) async {
    Database? db = await instance.database;
    return await db?.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
///////////////////////////////////////////////////////////////////////////////
  //The data present in the table is returned as a List of Map, where each row is of type map
  Future<List<Map<String, dynamic>>?> queryAllRows() async {
    Database? db = await instance.database;
    return await db?.query(table);
  }

 // All of the methods (insert, query, update, delete) can also be done using
 // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $table'));
  }
}
