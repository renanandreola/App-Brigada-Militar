import 'package:app_brigada_militar/database/db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

class User {
  int? id = null;
  String? name = null;
  final String email;
  String password;

  User({
    this.id,
    this.name,
    required this.email,
    required this.password,
  });

  /**
   * Convert a User into a Map. The keys must correspond
   * to the names of the columns in the database
   */
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  /**
   * Inserts or updates a database User
   */
  Future<bool> save() async {
    try {
      final db = await DB.instance.database;

      // Encrypt password using bcrypt
      var salt = await FlutterBcrypt.saltWithRounds(rounds: 10);
      this.password =
          await FlutterBcrypt.hashPw(password: this.password, salt: salt);

      await db.insert(
        'users',
        this.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return true;
    } catch (err) {
      print(err);

      return false;
    }
  }
}

/**
 * Authenticate User
 * 
 * @return bool user authenticated
 */
Future<bool> authenticate(String email, String password) async {
  try {
    final db = await DB.instance.database;

    // First check for a user using same email
    var user = await db.query(
      'users',
      columns: ['email', 'password'],
      where: 'email = "${email}"',
      limit: 1,
    );

    // User email found
    if (user.length > 0) {
      bool checkPassword = await FlutterBcrypt.verify(
          password: password, hash: user[0]['password']);

      return checkPassword;
    }

    return false;
  } catch (err) {
    print(err);
    return false;
  }
}

/**
 * Public method searchUser
 * 
 * Searchs for one or multiple users in the database
 */
Future<dynamic> searchUser({
  String? id,
  String? name,
  String? email,
  int limit = 50,
  String order = 'DESC',
  int page = 1,
}) async {
  try {
    var db = await DB.instance.database;

    Map<String, dynamic> params = {'id': id, 'name': name, 'email': email};

    // Verify filled params
    params.removeWhere((key, value) => value == null);

    String? whereParams =
        (params.length > 0) ? _createWhereParams(params) : null;

    return await db.query(
      'users',
      where: whereParams,
      limit: limit,
      orderBy: "users.email ${order}",
      offset: (page - 1) * limit,
    );
  } catch (err) {
    print(err);
    return false;
  }
}

String _createWhereParams(Map<String, dynamic> params) {
  String queryParams = '';

  params.forEach((key, param) {
    queryParams += ' OR ${key} = "${param}"';
  });

  return queryParams.substring(4);
}
