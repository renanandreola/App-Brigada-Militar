import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/utils/createWhereParams.dart';
import 'package:app_brigada_militar/database/utils/datetimeToStr.dart';
import 'package:sqflite/sqflite.dart';

/**
 * Vehicles entity class
 */
class Vehicle {
  String? id;
  String? name;
  String? brand;
  String? createdAt;
  String? updatedAt;

  Vehicle({
    this.id,
    this.name,
    this.brand,
    this.createdAt,
    this.updatedAt,
  });

  /**
   * Convert a Vehicle into a Map. The keys must correspond
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
   * Inserts a database Vehicle
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
        'vehicles',
        this.toMap(),
      );

      return true;
    } catch (err) {
      print(err);

      throw err;
    }
  }

  /**
   * Updates a database Vehicles
   */
  Future<bool> update({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      // Check entity
      if (this.id == null) throw "Você não pode atualizar uma veículo novo";

      final DateTime now = DateTime.now();
      String datetimeStr = datetimeToStr(now);

      this.updatedAt = datetimeStr;

      await db.update(
        'vehicles',
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
   * Deletes a Vehicles
   */
  Future<bool> delete({var transaction = null}) async {
    try {
      final db = await DB.instance.database;

      // Check entity
      if (this.id == null)
        throw "Você não pode deletar um veículo antes de salvá-lo";

      await db.delete(
        'vehicles',
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
 * Class to do Vehicle operations
 */
class VehicleTable {
  /**
   * Public Method find
   * 
   * Searchs for one or multiple Vehicles in the database
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

      List<Map> queryVehicles = await db.query(
        'vehicles',
        where: whereParams,
        limit: limit,
        orderBy: "vehicles.${orderField} ${order}",
        offset: (page - 1) * limit,
      );

      List<Vehicle> vehicles = [];

      queryVehicles.forEach((queryVehicle) {
        vehicles.add(Vehicle(
          id: queryVehicle['_id'],
          name: queryVehicle['firstname'],
          brand: queryVehicle['lastname'],
          createdAt: queryVehicle['createdAt'],
          updatedAt: queryVehicle['updatedAt'],
        ));
      });

      return vehicles;
    } catch (err) {
      print(err);

      throw err;
    }
  }
}
