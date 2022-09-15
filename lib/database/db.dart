import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart' as path;

class DB {
  // Create database unique instance
  DB._();
  static final DB instance = DB._();
  static sqflite.Database? _database;

  get database async {
    if (_database != null) return _database;

    return await _initDatabase();
  }

  /**
   * Start a database
   */
  _initDatabase() async {
    print(await sqflite.getDatabasesPath());
    return await sqflite.openDatabase(
      path.join("/storage/emulated/0/Download", 'novorumo.db'),
      version: 1,
      onCreate: _onCreateDatabase,
    );
  }

  /**
   * Create database commands
   */
  _onCreateDatabase(db, version) async {
    await db.execute(_user);
    await db
        .insert('users', {'email': 'diogola3@gmail.com', 'password': '12345'});
  }

  // Define User Table
  String get _user => '''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email VARCHAR(255),
      password VARCHAR(255)
    );
  ''';
}
