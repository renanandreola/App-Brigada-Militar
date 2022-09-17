/**
 * @class CopyDatabase
 * 
 * create a copy of the original api database into the sqlite database
 */
class CopyAPIDatabase {
  /**
   * Manages the tables and inserts needed to start the database
   */
  void executeAll(db, version) async {
    await db.execute(_user);
    await db.execute(_userIdTrigger);
    await db.execute(_properties);
    await db.execute(_owners);
  }

  /**
   * Create Users Table
   */
  String get _user => '''
    CREATE TABLE users (
      id VARCHAR(255) PRIMARY KEY,
      name VARCHAR(255),
      email VARCHAR(255),
      password VARCHAR(255)
    );
  ''';

  /**
   * Set a trigger to always generate a uuid
   */
  String get _userIdTrigger => '''
    CREATE TRIGGER AutoGenerateGUID_RELATION_3
    AFTER INSERT ON users
    FOR EACH ROW
    WHEN (NEW.id IS NULL)
    BEGIN
      UPDATE users SET id = (select lower(hex(randomblob(12)))) WHERE rowid = NEW.rowid;
    END;
  ''';

  /**
   * Create Properties Table
   */
  String get _properties => '''
    CREATE TABLE properties (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR(255)
    );
  ''';

  /**
   * Create Owners Table
   */
  String get _owners => '''
    CREATE TABLE owners (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR(255)
    );
  ''';
}
