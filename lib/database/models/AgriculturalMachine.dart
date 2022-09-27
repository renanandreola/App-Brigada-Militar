import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/utils/createWhereParams.dart';
import 'package:app_brigada_militar/database/utils/datetimeToStr.dart';
import 'package:sqflite/sqflite.dart';

/**
 * AgriculturalMachines entity class
 */
class AgriculturalMachine {
  String? id;
  String? name;
  String? brand;
  String? createdAt;
  String? updatedAt;

  AgriculturalMachine({
    this.id,
    this.name,
    this.brand,
    this.createdAt,
    this.updatedAt,
  });

  /**
   * Convert a AgriculturalMachine into a Map. The keys must correspond
   * to the names of the columns in the database
   */
  Map<String, dynamic> toMap() {
    return {
      '_id': this.id,
      'name': this.name,
      'brand': this.brand,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
    };
  }

  /**
   * Inserts a database AgriculturalMachine
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
        'agricultural_machines',
        this.toMap(),
      );

      return true;
    } catch (err) {
      print(err);

      throw err;
    }
  }

  /**
   * Updates a database AgriculturalMachines
   */
  Future<bool> update({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      // Check entity
      if (this.id == null) throw "Você não pode atualizar uma máquina agrícola nova";

      final DateTime now = DateTime.now();
      String datetimeStr = datetimeToStr(now);

      this.updatedAt = datetimeStr;

      await db.update(
        'agricultural_machines',
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
   * Deletes a AgriculturalMachines
   */
  Future<bool> delete({var transaction = null}) async {
    try {
      final db = await DB.instance.database;

      // Check entity
      if (this.id == null)
        throw "Você não pode deletar uma máquina agrícola antes de salvá-la";

      await db.delete(
        'agricultural_machines',
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
 * Class to do AgriculturalMachine operations
 */
class AgriculturalMachineTable {
  /**
   * Public Method find
   * 
   * Searchs for one or multiple AgriculturalMachines in the database
   */
  Future<dynamic> find({
    String? id,
    String? name,
    String? brand,
    int limit = 50,
    String order = 'DESC',
    String orderField = 'name',
    int page = 1,
  }) async {
    try {
      final db = await DB.instance.database;

      Map<String, dynamic> params = {
        '_id': id,
        'firstname': name,
        'lastname': brand,
      };

      // Verify filled params
      params.removeWhere((key, value) => value == null);

      String? whereParams =
          (params.length > 0) ? createWhereParams(params) : null;

      List<Map> queryAgriculturalMachines = await db.query(
        'agricultural_machines',
        where: whereParams,
        limit: limit,
        orderBy: "agricultural_machines.${orderField} ${order}",
        offset: (page - 1) * limit,
      );

      List<AgriculturalMachine> agricultural_machines = [];

      queryAgriculturalMachines.forEach((queryAgriculturalMachine) {
        agricultural_machines.add(AgriculturalMachine(
          id: queryAgriculturalMachine['_id'],
          name: queryAgriculturalMachine['firstname'],
          brand: queryAgriculturalMachine['lastname'],
          createdAt: queryAgriculturalMachine['createdAt'],
          updatedAt: queryAgriculturalMachine['updatedAt'],
        ));
      });

      return agricultural_machines;
    } catch (err) {
      print(err);

      throw err;
    }
  }
}
