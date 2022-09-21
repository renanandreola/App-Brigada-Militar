import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/utils/createWhereParams.dart';
import 'package:app_brigada_militar/database/utils/datetimeToStr.dart';
import 'package:sqflite/sqflite.dart';

/**
 * Owner entity class
 */
class PropertyType {
  String? id;
  String name;
  String? createdAt;
  String? updatedAt;

  PropertyType({
    this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  /**
   * Convert a PropertyType into a Map. The keys must correspond
   * to the names of the columns in the database
   */
  Map<String, dynamic> toMap() {
    return {
      '_id': this.id,
      'name': this.name,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
    };
  }

  /**
   * Inserts a database PropertyType
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
        'property_types',
        this.toMap(),
      );

      return true;
    } catch (err) {
      print(err);

      throw err;
    }
  }

  /**
   * Updates a database PropertyType
   */
  Future<bool> update({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      // Check entity
      if (this.id == null)
        throw "Você não pode atualizar um tipo de propriedade novo";

      final DateTime now = DateTime.now();
      String datetimeStr = datetimeToStr(now);

      this.updatedAt = datetimeStr;

      await db.update(
        'property_types',
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
   * Deletes a PropertyType
   */
  Future<bool> delete({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      // Check entity
      if (this.id == null)
        throw "Você não pode deletar um tipo de propriedade antes de salvá-lo";

      await db.delete(
        'property_types',
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
 * Class to do PropertyType operations
 */
class PropertyTypesTable {
  /**
   * Public Method find
   * 
   * Searchs for one or multiple PropertyTypes in the database
   */
  Future<dynamic> find({
    String? id,
    String? name,
    int limit = 50,
    String order = 'DESC',
    int page = 1,
  }) async {
    try {
      final db = await DB.instance.database;

      Map<String, dynamic> params = {
        '_id': id,
        'name': name,
      };

      // Verify filled params
      params.removeWhere((key, value) => value == null);

      String? whereParams =
          (params.length > 0) ? createWhereParams(params) : null;

      List<Map> queryPropertyTypes = await db.query(
        'property_types',
        where: whereParams,
        limit: limit,
        orderBy: "property_types.name ${order}",
        offset: (page - 1) * limit,
      );

      List<PropertyType> propertyTypes = [];

      queryPropertyTypes.forEach((queryPropertyType) {
        propertyTypes.add(PropertyType(
          id: queryPropertyType['_id'],
          name: queryPropertyType['name'],
          createdAt: queryPropertyType['createdAt'],
          updatedAt: queryPropertyType['updatedAt'],
        ));
      });

      return propertyTypes;
    } catch (err) {
      print(err);

      throw err;
    }
  }
}
