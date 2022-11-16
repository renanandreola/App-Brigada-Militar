import 'package:app_brigada_militar/database/copy_api_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/**
 * Class DB
 * 
 * Main class that manages the sqlite database
 */
class DB {
  /**
   * Create a unique instance database
   */
  DB._();
  static final DB instance = DB._();
  static Database? _database;

  /**
   * Get database 
   * 
   * @return SqliteDatabaseBase database
   */
  get database async {
    if (_database != null) return _database;

    return await _initDatabase();
  }

  /**
   * Start a database or create one if not exists
   */
  _initDatabase() async {
    // return await deleteDatabase(join("/storage/emulated/0/Download", 'defaultdb.db'));
    return await openDatabase(
      join("/storage/emulated/0/Download", 'testemarlon.db'),
      // join(await getDatabasesPath(), 'database.db'),
      version: 1,
      onCreate: copyAPIDatabase,
    );
  }
}
