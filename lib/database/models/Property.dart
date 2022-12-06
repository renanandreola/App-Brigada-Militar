import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/utils/createWhereParams.dart';
import 'package:app_brigada_militar/database/utils/datetimeToStr.dart';
import 'package:sqflite/sqflite.dart';

/**
 * Property Entity class
 */
class Property {
  String? id;
  String? code;
  bool? has_geo_board;
  int? qty_people;
  bool? has_cams;
  bool? has_phone_signal;
  bool? has_internet;
  bool? has_gun;
  bool? has_gun_local;
  String? gun_local_description;
  String? qty_agricultural_defensives;
  String? area;
  String? observations;
  String latitude;
  String longitude;
  String? createdAt;
  String? updatedAt;
  String fk_owner_id;
  String fk_property_type_id;

  Property({
    this.id,
    this.code,
    this.has_geo_board,
    this.qty_people,
    this.has_cams,
    this.has_phone_signal,
    this.has_internet,
    this.has_gun,
    this.has_gun_local,
    this.gun_local_description,
    this.area,
    this.qty_agricultural_defensives,
    this.observations,
    required this.latitude,
    required this.longitude,
    this.createdAt,
    this.updatedAt,
    required this.fk_owner_id,
    required this.fk_property_type_id,
  });

  /**
   * Convert a Property into a Map. The keys must correspond
   * to the names of the columns in the database
   */
  Map<String, dynamic> toMap() {
    return {
      '_id': this.id,
      'code': this.code,
      'has_geo_board': this.has_geo_board,
      'qty_people': this.qty_people,
      'has_cams': this.has_cams,
      'has_phone_signal': this.has_phone_signal,
      'has_internet': this.has_internet,
      'has_gun': this.has_gun,
      'has_gun_local': this.has_gun_local,
      'gun_local_description': this.gun_local_description,
      'qty_agricultural_defensives': this.qty_agricultural_defensives,
      'area': this.area,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'observations': this.observations,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
      'fk_owner_id': this.fk_owner_id,
      'fk_property_type_id': this.fk_property_type_id,
    };
  }

  /**
   * Inserts a database Property
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
        'properties',
        this.toMap(),
      );

      var properties = await db.query(
        'properties',
        orderBy: "createdAt DESC",
        limit: 1
      );

      var property = properties[0];

      await db.insert(
        'database_updates',
        {
          'reference_table': 'properties',
          'updated_id': property["_id"]
        }
      );

      return property["_id"];
    } catch (err) {
      print(err);

      throw err;
    }
  }

  /**
   * Updates a database Property
   */
  Future<bool> update({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      // Check Entity
      if (this.id == null) throw "Você não pode atualizar uma propriedade nova";

      final DateTime now = DateTime.now();
      String datetimeStr = datetimeToStr(now);

      this.updatedAt = datetimeStr;

      await db.update(
        'properties',
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
   * Deletes a Porperty
   */
  Future<bool> delete({var transaction = null}) async {
    try {
      final db =
          (transaction != null) ? transaction : await DB.instance.database;

      // Check Entity
      if (this.id == null)
        throw "Você não pode deletar uma propriedade antes de salvá-la";

      await db.delete(
        'properties',
        where: "_id = '${this.id}'",
      );

      return true;
    } catch (err) {
      throw err;
    }
  }
}

/**
 * Property Table class
 */
class PropertyTable {
  /**
   * Public method find
   * 
   * Searchs for one or multiple properties in the database
   */
  Future<dynamic> find({
    String? id,
    String? code,
    bool? has_geo_board,
    int? qty_people,
    bool? has_cams,
    bool? has_phone_signal,
    bool? has_internet,
    bool? has_gun,
    bool? has_gun_local,
    String? gun_local_description,
    String? qty_agricultural_defensives,
    String? area,
    String? observations,
    int limit = 50,
    String order = 'DESC',
    String orderField = 'createdAt',
    int page = 1,
  }) async {
    try {
      final db = await DB.instance.database;

      Map<String, dynamic> params = {
        '_id': id,
        'code': code,
        'has_geo_board': has_geo_board,
        'qty_people': qty_people,
        'has_cams': has_cams,
        'has_phone_signal': has_phone_signal,
        'has_internet': has_internet,
        'has_gun': has_gun,
        'has_gun_local': has_gun_local,
        'gun_local_description': gun_local_description,
        'qty_agricultural_defensives': qty_agricultural_defensives,
        'area': area,
        'observations': observations,
      };

      // Verify filled params
      params.removeWhere((key, value) => value == null);

      String? whereParams =
          (params.length > 0) ? createWhereParams(params) : null;

      List<Map> queryProperties = await db.query(
        'properties',
        where: whereParams,
        limit: limit,
        orderBy: "properties.${orderField} ${order}",
        offset: (page - 1) * limit,
      );

      List<Property> properties = [];

      queryProperties.forEach((queryProperty) async {
        properties.add(Property(
          id: queryProperty['_id'],
          code: queryProperty['name'],
          has_geo_board: queryProperty['has_geo_board'],
          qty_people: queryProperty['qty_people'],
          has_cams: queryProperty['has_cams'],
          has_phone_signal: queryProperty['has_phone_signal'],
          has_internet: queryProperty['has_internet'],
          has_gun: queryProperty['has_gun'],
          has_gun_local: queryProperty['has_gun_local'],
          gun_local_description: queryProperty['gun_local_description'],
          qty_agricultural_defensives: queryProperty['qty_agricultural_defensives'],
          area: queryProperty['area'],
          latitude: queryProperty['latitude'],
          longitude: queryProperty['longitude'],
          observations: queryProperty['observations'],
          createdAt: queryProperty['createdAt'],
          updatedAt: queryProperty['updatedAt'],
          fk_owner_id: queryProperty['fk_owner_id'],
          fk_property_type_id: queryProperty['fk_property_type_id'],
        ));
      });

      return properties;
    } catch (err) {
      print(err);

      throw err;
    }
  }
}
