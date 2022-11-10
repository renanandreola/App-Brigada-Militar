import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/utils/createWhereParams.dart';
import 'package:app_brigada_militar/database/utils/datetimeToStr.dart';
import 'package:sqflite/sqflite.dart';

/**
 * Owner entity class
 */
class Owner {
  String? id;
  String firstname;
  String lastname;
  String cpf;
  String phone1;
  String? phone2;
  String? createdAt;
  String? updatedAt;

  Owner({
    this.id,
    required this.firstname,
    required this.lastname,
    required this.cpf,
    required this.phone1,
    this.phone2,
    this.createdAt,
    this.updatedAt,
  });

  /**
   * Convert a Owner into a Map. The keys must correspond
   * to the names of the columns in the database
   */
  Map<String, dynamic> toMap() {
    return {
      '_id': this.id,
      'firstname': this.firstname,
      'lastname': this.lastname,
      'cpf': this.cpf,
      'phone1': this.phone1,
      'phone2': this.phone2,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
    };
  }

  /**
   * Inserts a database Property Owner
   */
  Future<dynamic> save({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      final DateTime now = DateTime.now();
      String datetimeStr = datetimeToStr(now);

      this.createdAt = datetimeStr;
      this.updatedAt = datetimeStr;

      await db.insert(
        'owners',
        this.toMap(),
      );

      var owners = await db.query(
        'owners',
        where: "firstname = '${this.firstname}' and lastname = '${this.lastname}'"
      );

      var owner = owners[0];

      await db.insert(
        'database_updates',
        {
          'reference_table': 'owners',
          'updated_id': owner["_id"]
        }
      );

      return owner["_id"];
    } catch (err) {
      print(err);

      throw err;
    }
  }

  /**
   * Updates a database property owner
   */
  Future<bool> update({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      // Check entity
      if (this.id == null) throw "Você não pode atualizar um proprietário novo";

      final DateTime now = DateTime.now();
      String datetimeStr = datetimeToStr(now);

      this.updatedAt = datetimeStr;

      await db.update(
        'owners',
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
   * Deletes a property owner
   */
  Future<bool> delete({var transaction = null}) async {
    try {
      final db = await DB.instance.database;

      // Check entity
      if (this.id == null)
        throw "Você não pode deletar um usuário antes de salvá-lo";

      await db.delete(
        'owners',
        where: "_id = '${this.id}'",
      );

      return true;
    } catch (err) {
      print(err);

      throw err;
    }
  }
}

/**
 * Class to do Owner operations
 */
class OwnersTable {
  /**
   * Public Method find
   * 
   * Searchs for one or multiple owners in the database
   */
  Future<dynamic> find({
    String? id,
    String? firstname,
    String? lastname,
    int limit = 50,
    String order = 'DESC',
    String orderField = 'firstname',
    int page = 1,
  }) async {
    try {
      final db = await DB.instance.database;

      Map<String, dynamic> params = {
        '_id': id,
        'firstname': firstname,
        'lastname': lastname,
      };

      // Verify filled params
      params.removeWhere((key, value) => value == null);

      String? whereParams =
          (params.length > 0) ? createWhereParams(params) : null;

      List<Map> queryOwners = await db.query(
        'owners',
        where: whereParams,
        limit: limit,
        orderBy: "owners.${orderField} ${order}",
        offset: (page - 1) * limit,
      );

      List<Owner> owners = [];

      queryOwners.forEach((queryOwner) {
        owners.add(Owner(
          id: queryOwner['_id'],
          firstname: queryOwner['firstname'],
          lastname: queryOwner['lastname'],
          phone1: queryOwner["phone1"],
          phone2: queryOwner["phone2"],
          cpf: queryOwner["cpf"],
          createdAt: queryOwner['createdAt'],
          updatedAt: queryOwner['updatedAt'],
        ));
      });

      return owners;
    } catch (err) {
      print(err);

      throw err;
    }
  }
}
