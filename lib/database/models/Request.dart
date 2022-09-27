import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/utils/createWhereParams.dart';
import 'package:app_brigada_militar/database/utils/datetimeToStr.dart';
import 'package:sqflite/sqflite.dart';

/**
 * Requests entity class
 */
class Request {
  String? id;
  String agency;
  bool has_success = false;
  String? createdAt;
  String? updatedAt;
  String fk_property_id;

  Request({
    this.id,
    required this.agency,
    required this.has_success,
    this.createdAt,
    this.updatedAt,
    required this.fk_property_id,
  });

  /**
   * Convert a Request into a Map. The keys must correspond
   * to the names of the columns in the database
   */
  Map<String, dynamic> toMap() {
    return {
      '_id': this.id,
      'agency': this.agency,
      'has_success': this.has_success,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
      'fk_property_id': this.fk_property_id,
    };
  }

  /**
   * Inserts a database Request
   */
  Future<bool> save({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      final DateTime now = DateTime.now();
      String datetimeStr = datetimeToStr(now);

      this.createdAt = datetimeStr;
      this.updatedAt = datetimeStr;

      await db.insert(
        'requests',
        this.toMap(),
      );

      return true;
    } catch (err) {
      print(err);

      throw err;
    }
  }

  /**
   * Updates a database Requests
   */
  Future<bool> update({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      // Check entity
      if (this.id == null) throw "Você não pode atualizar uma solicitação nova";

      final DateTime now = DateTime.now();
      String datetimeStr = datetimeToStr(now);

      this.updatedAt = datetimeStr;

      await db.update(
        'requests',
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
   * Deletes a Requests
   */
  Future<bool> delete({var transaction = null}) async {
    try {
      final db = await DB.instance.database;

      // Check entity
      if (this.id == null)
        throw "Você não pode deletar uma solicitação antes de salvá-la";

      await db.delete(
        'requests',
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
 * Class to do Request operations
 */
class RequestTable {
  /**
   * Public Method find
   * 
   * Searchs for one or multiple Requests in the database
   */
  Future<dynamic> find({
    String? id,
    String? agency,
    bool? has_success,
    int limit = 50,
    String order = 'DESC',
    String orderField = 'name',
    int page = 1,
  }) async {
    try {
      final db = await DB.instance.database;

      Map<String, dynamic> params = {
        '_id': id,
        'agency': agency,
        'has_success': has_success,
      };

      // Verify filled params
      params.removeWhere((key, value) => value == null);

      String? whereParams =
          (params.length > 0) ? createWhereParams(params) : null;

      List<Map> queryRequests = await db.query(
        'requests',
        where: whereParams,
        limit: limit,
        orderBy: "requests.${orderField} ${order}",
        offset: (page - 1) * limit,
      );

      List<Request> requests = [];

      queryRequests.forEach((queryRequest) {
        requests.add(Request(
          id: queryRequest['_id'],
          agency: queryRequest['agency'],
          has_success: queryRequest['has_success'],
          createdAt: queryRequest['createdAt'],
          updatedAt: queryRequest['updatedAt'],
          fk_property_id: queryRequest['fk_property_id'],
        ));
      });

      return requests;
    } catch (err) {
      print(err);

      throw err;
    }
  }
}
