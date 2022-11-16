import 'dart:convert';
import 'package:app_brigada_militar/database/sync/apiToken.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

Future<String?> syncProperties () async {

  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  String uri = "https://novorumo-api.fly.dev/api/sync/properties";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    
    String query = "INSERT INTO properties (_id, code, has_geo_board, qty_people, has_cams, has_phone_signal, has_internet, has_gun, has_gun_local, gun_local_description, qty_agricultural_defensives, observations, latitude,longitude, fk_owner_id, fk_property_type_id, latitude, longitude, createdAt, updatedAt) VALUES";

    var properties = jsonDecode(response.body);

    try {
      for (var property in properties) {

        List columns = [
          '_id',
          'code',
          'gun_local_description',
          'observations',
          'fk_owner_id',
          'fk_property_type_id',
          'created_at',
          'updated_at'
        ];

        for (String column in columns) {
          property[column] = property[column] != null ? property[column].replaceAll("'", "''") : null;
        }

        String queryInsertLine = "\n('${property["_id"]}', '${property["code"]}', '${property["has_geo_board"]}', '${property["qty_people"]}', '${property["has_cams"]}', '${property["has_phone_signal"]}', '${property["has_internet"]}', '${property["has_gun"]}', '${property["has_gun_local"]}', '${property["gun_local_description"]}', '${property["qty_agricultural_defensives"]}', '${property["observations"]}', '${property["latitude"]}', '${property["longitude"]}', '${property["fk_owner_id"]}', '${property["fk_property_type_id"]}', '${property["latitude"]}', '${property["longitude"]}', '${property["created_at"]}', '${property["updated_at"]}'),";

        query += queryInsertLine;
      }

      if (properties.length > 0) {
        query = query.substring(0, query.length - 1) + ";";

        return query;
      }

      return null;
    } catch ($e) {
      throw $e;
    }
  }

  if (jsonDecode(response.body).containsKey("status") && jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return syncProperties();
  }

  throw Exception("Request error");
}

updateProperties(db) async {
  await sendNewPropertyData(db);
  // await receiveNewPropertyData(db);
}

receiveNewPropertyData(db) async {
  var lastSyncDate = await db.query(
    'sync',
    limit: 1
  );

  if (lastSyncDate.length <= 0) {
    throw Exception("Failed to Update. Cannot find Last sync date information");
  }

  lastSyncDate = lastSyncDate[0]["last_sync"];

  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  String uri = "https://novorumo-api.fly.dev/api/sync/properties?last_date=${lastSyncDate}";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    String query = "INSERT INTO properties (_id, code, has_geo_board, qty_people, has_cams, has_phone_signal, has_internet, has_gun, has_gun_local, gun_local_description, qty_agricultural_defensives, observations, latitude, longitude, fk_owner_id, fk_property_type_id, latitude, longitude, createdAt, updatedAt) VALUES";

    var responseBody = jsonDecode(response.body);
    var properties = responseBody["properties"];
    var deleted = responseBody["deleted"];

    try {
      for (var property in properties) {
        // Check if entity is in the Sqlite database
        var current_property = await db.query(
          'properties',
          where: "_id = '${property["_id"]}'",
          limit: 1
        );

        // Convert to sqlite table format
        Map<String, dynamic> propertySqlite = {
          '_id': property["_id"],
          'code': property["code"],
          'has_geo_board': property["has_geo_board"],
          'qty_people': property["qty_people"],
          'has_cams': property["has_cams"],
          'has_phone_signal': property["has_phone_signal"],
          'has_internet': property["has_internet"],
          'has_gun': property["has_gun"],
          'has_gun_local': property["has_gun_local"],
          'gun_local_description': property["gun_local_description"],
          'qty_agricultural_defensives': property["qty_agricultural_defensives"],
          'observations': property["observations"],
          'latitude': property["latitude"],
          'longitude': property["longitude"],
          'fk_owner_id': property["fk_owner_id"],
          'fk_property_type_id': property["fk_property_type_id"],
          'createdAt': property["created_at"],
          'updatedAt': property["updated_at"],
        };

        // If entity is in the database, do the update
        if (current_property.length > 0) {

          await db.update(
            'properties',
            propertySqlite,
            where: "_id = '${current_property[0]["_id"]}'",
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

        } else { // Do insert
          await db.insert(
            'properties',
            propertySqlite,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }


      for (var del in deleted) {
        var current_property = await db.query(
          'properties',
          where: "_id = '${del["_id"]}'",
          limit: 1
        );

        if (current_property.length > 0) {
          await db.delete(
            'properties',
            where: "_id = '${del["deleted_id"]}'",
          );
        }

      }

      return true;
    } catch ($e) {
      throw $e;
    }
  }

  if (jsonDecode(response.body).containsKey("status") && jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return receiveNewPropertyData(db);
  }

  throw Exception("Request error");
}

sendNewPropertyData(db) async {
  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  // Check if database has updated
  var updates = await db.query(
    'database_updates',
    where: "reference_table = 'properties'",
  );

  List<Map> propertyChanges = [];

  for (var update in updates) {
    List<Map> properties = await db.query(
      'properties',
      where: "_id = '${update["updated_id"]}'",
      limit: 1,
    );

    Map property = properties[0];

    propertyChanges.add(property);
  }

  // Check if database has deleted
  var deleted = await db.query(
    'garbages',
    where: "reference_table = 'properties'",
  );

  List propertyDeletes = [];

  for (var del in deleted) {
    propertyDeletes.add(del["deleted_id"]);
  }

  var allChanges = {'properties': propertyChanges, 'deleted': propertyDeletes };

  String propertiesJson = jsonEncode(allChanges);

  String uri = "https://novorumo-api.fly.dev/api/sync/properties";
  final response = await http.post(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}", "Content-Type": "application/json", "Accept": "application/json" }, body: propertiesJson);

  if (jsonDecode(response.body).containsKey("status") && jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return sendNewPropertyData(db);
  }

  if (response.statusCode == 201 && jsonDecode(response.body).containsKey("updated")) {
    await db.rawDelete("DELETE FROM database_updates WHERE reference_table = 'properties'");
    await db.rawDelete("DELETE FROM garbages WHERE reference_table = 'properties'");
  
    return true;
  }

  throw Exception("Não foi possível sincronizar os usuários");
}