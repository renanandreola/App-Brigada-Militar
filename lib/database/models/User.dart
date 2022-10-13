import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/utils/createWhereParams.dart';
import 'package:app_brigada_militar/database/utils/datetimeToStr.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

/**
 * User Entity class
 */
class User {
  String? id = null;
  String? name = null;
  String email;
  String password;
  String? createdAt;
  String? updatedAt;

  User({
    this.id,
    this.name,
    required this.email,
    required this.password,
    this.createdAt,
    this.updatedAt,
  });

  /**
   * Convert a User into a Map. The keys must correspond
   * to the names of the columns in the database
   */
  Map<String, dynamic> toMap() {
    return {
      '_id': this.id,
      'name': this.name,
      'email': this.email,
      'password': this.password,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
    };
  }

  /**
   * Inserts a database User
   */
  Future<bool> save({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      // Encrypt password using bcrypt
      var salt = await FlutterBcrypt.saltWithRounds(rounds: 10);
      this.password =
          await FlutterBcrypt.hashPw(password: this.password, salt: salt);

      final DateTime now = DateTime.now();
      String datetimeStr = datetimeToStr(now);

      this.createdAt = datetimeStr;
      this.updatedAt = datetimeStr;

      await db.insert(
        'users',
        this.toMap(),
      );

      return true;
    } catch (err) {
      throw err;
    }
  }

  /**
   * Updates a database User
   */
  Future<bool> update({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      // Check Entity
      if (this.id == null) throw "Você não pode atualizar um usuário novo";

      // Check Password
      List<User> users = await UsersTable().find(id: this.id);
      User user = users[0];

      if (user.password != this.password) {
        // Encrypt password using bcrypt
        var salt = await FlutterBcrypt.saltWithRounds(rounds: 10);
        this.password =
            await FlutterBcrypt.hashPw(password: this.password, salt: salt);
      }

      final DateTime now = DateTime.now();
      String datetimeStr = datetimeToStr(now);

      this.updatedAt = datetimeStr;

      await db.update(
        'users',
        this.toMap(),
        where: "_id = '${this.id}'",
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return true;
    } catch (err) {
      print(err);

      throw err;
    }
  }

  /**
   * Deletes a User
   */
  Future<bool> delete({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      // Check Entity
      if (this.id == null)
        throw "Você não pode deletar um usuário antes de salvá-lo";

      await db.delete(
        'users',
        where: "_id = '${this.id}'",
      );

      return true;
    } catch (err) {
      throw err;
    }
  }
}

/**
 * Class to do Users operations
 */
class UsersTable {
  /**
   * Public method find
   * 
   * Searchs for one or multiple users in the database
   */
  Future<dynamic> find({
    String? id,
    String? name,
    String? email,
    int limit = 50,
    String order = 'DESC',
    String orderField = 'email',
    int page = 1,
  }) async {
    try {
      final db = await DB.instance.database;

      Map<String, dynamic> params = {'_id': id, 'name': name, 'email': email};

      // Verify filled params
      params.removeWhere((key, value) => value == null);

      String? whereParams =
          (params.length > 0) ? createWhereParams(params) : null;

      List<Map> queryUsers = await db.query(
        'users',
        where: whereParams,
        limit: limit,
        orderBy: "users.${orderField} ${order}",
        offset: (page - 1) * limit,
      );

      List<User> users = [];

      queryUsers.forEach((queryUser) {
        users.add(User(
          id: queryUser['_id'],
          name: queryUser['name'],
          email: queryUser['email'],
          password: queryUser['password'],
          createdAt: queryUser['createdAt'],
          updatedAt: queryUser['updatedAt'],
        ));
      });

      return users;
    } catch (err) {
      print(err);

      throw err;
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

      throw err;
    }
  }
}
