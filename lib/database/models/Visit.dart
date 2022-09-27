import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/utils/createWhereParams.dart';
import 'package:app_brigada_militar/database/utils/datetimeToStr.dart';
import 'package:sqflite/sqflite.dart';

/**
 * Visits entity class
 */
class Visit {
  String? id;
  String car;
  String latitude;
  String longitude;
  String visit_date;
  String? createdAt;
  String? updatedAt;

  Visit({
    this.id,
    required this.car,
    required this.latitude,
    required this.longitude,
    required this.visit_date,
    this.createdAt,
    this.updatedAt,
  });

  /**
   * Convert a Visit into a Map. The keys must correspond
   * to the names of the columns in the database
   */
  Map<String, dynamic> toMap() {
    return {
      '_id': this.id,
      'car': this.car,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'visit_date': this.visit_date,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
    };
  }

  /**
   * Inserts a database Visit
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
        'visits',
        this.toMap(),
      );

      return true;
    } catch (err) {
      print(err);

      throw err;
    }
  }

  /**
   * Updates a database Visits
   */
  Future<bool> update({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      // Check entity
      if (this.id == null) throw "Você não pode atualizar uma visita nova";

      final DateTime now = DateTime.now();
      String datetimeStr = datetimeToStr(now);

      this.updatedAt = datetimeStr;

      await db.update(
        'visits',
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
   * Deletes a Visits
   */
  Future<bool> delete({var transaction = null}) async {
    try {
      final db = await DB.instance.database;

      // Check entity
      if (this.id == null)
        throw "Você não pode deletar uma visita antes de salvá-la";

      await db.delete(
        'visits',
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
 * Class to do Visit operations
 */
class VisitTable {
  /**
   * Public Method find
   * 
   * Searchs for one or multiple Visits in the database
   */
  Future<dynamic> find({
    String? id,
    String? car,
    String? latitude,
    String? longitude,
    String? visit_date,
    int limit = 50,
    String order = 'DESC',
    String orderField = 'name',
    int page = 1,
  }) async {
    try {
      final db = await DB.instance.database;

      Map<String, dynamic> params = {
        '_id': id,
        'car': car,
        'latitude': latitude,
        'longitude': longitude,
        'visit_date': visit_date
      };

      // Verify filled params
      params.removeWhere((key, value) => value == null);

      String? whereParams =
          (params.length > 0) ? createWhereParams(params) : null;

      List<Map> queryVisits = await db.query(
        'visits',
        where: whereParams,
        limit: limit,
        orderBy: "visits.${orderField} ${order}",
        offset: (page - 1) * limit,
      );

      List<Visit> visits = [];

      queryVisits.forEach((queryVisit) {
        visits.add(Visit(
          id: queryVisit['_id'],
          car: queryVisit['car'],
          latitude: queryVisit['latitude'],
          longitude: queryVisit['longitude'],
          visit_date: queryVisit['visit_date'],
          createdAt: queryVisit['createdAt'],
          updatedAt: queryVisit['updatedAt'],
        ));
      });

      return visits;
    } catch (err) {
      print(err);

      throw err;
    }
  }
}
