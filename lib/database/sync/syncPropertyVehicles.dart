import 'dart:convert';
import 'package:app_brigada_militar/database/sync/apiToken.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

Future<String?> syncPropertyVehicles() async {
  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  String uri =
      "http://ec2-107-21-160-174.compute-1.amazonaws.com:8002/api/sync/property-vehicles";
  final response = await http
      .get(Uri.parse(uri), headers: {"Authorization": "Bearer ${token}"});

  if (response.statusCode == 200) {
    String query =
        "INSERT INTO property_vehicles (_id, fk_vehicle_id, color, identification, fk_property_id, createdAt, updatedAt) VALUES";

    var property_vehicles = jsonDecode(response.body);

    try {
      for (var property_vehicle in property_vehicles) {
        property_vehicle["identification"] =
            property_vehicle["identification"] == null
                ? ""
                : property_vehicle["identification"];
        property_vehicle["color"] =
            property_vehicle["color"] == null ? "" : property_vehicle["color"];

        property_vehicle["_id"] =
            property_vehicle["_id"] == null ? "" : property_vehicle["_id"];

        property_vehicle["fk_vehicle_id"] =
            property_vehicle["fk_vehicle_id"] == null
                ? ""
                : property_vehicle["fk_vehicle_id"];

        property_vehicle["fk_property_id"] =
            property_vehicle["fk_property_id"] == null
                ? ""
                : property_vehicle["fk_property_id"];

        property_vehicle["created_at"] = property_vehicle["created_at"] == null
            ? ""
            : property_vehicle["created_at"];

        property_vehicle["updated_at"] = property_vehicle["updated_at"] == null
            ? ""
            : property_vehicle["updated_at"];

        String queryInsertLine =
            "\n('${property_vehicle["_id"].replaceAll("'", "''")}', '${property_vehicle["fk_vehicle_id"].replaceAll("'", "''")}', '${property_vehicle["color"].replaceAll("'", "''")}', '${property_vehicle["identification"].replaceAll("'", "''")}', '${property_vehicle["fk_property_id"].replaceAll("'", "''")}', '${property_vehicle["created_at"].replaceAll("'", "''")}', '${property_vehicle["updated_at"].replaceAll("'", "''")}'),";

        query += queryInsertLine;
      }

      if (property_vehicles.length > 0) {
        query = query.substring(0, query.length - 1) + ";";

        return query;
      }

      return null;
    } catch ($e) {
      throw $e;
    }
  }

  if (jsonDecode(response.body).containsKey("status") &&
      jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return syncPropertyVehicles();
  }

  throw Exception("Request error");
}

updatePropertyVehicles(db) async {
  await sendNewPropertyVehicleData(db);
  // await receiveNewPropertyVehicleData(db);
}

receiveNewPropertyVehicleData(db) async {
  var lastSyncDate = await db.query('sync', limit: 1);

  if (lastSyncDate.length <= 0) {
    throw Exception("Failed to Update. Cannot find Last sync date information");
  }

  lastSyncDate = lastSyncDate[0]["last_sync"];

  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  String uri =
      "http://ec2-107-21-160-174.compute-1.amazonaws.com:8002/api/sync/property-vehicles?last_date=${lastSyncDate}";
  final response = await http
      .get(Uri.parse(uri), headers: {"Authorization": "Bearer ${token}"});

  if (response.statusCode == 200) {
    String query =
        "INSERT INTO property_vehicles (_id, color, fk_vehicle_id, fk_property_id, createdAt, updatedAt) VALUES";

    var responseBody = jsonDecode(response.body);
    var property_vehicles = responseBody["property_vehicles"];
    var deleted = responseBody["deleted"];

    try {
      for (var property_vehicle in property_vehicles) {
        // Check if entity is in the Sqlite database
        var current_property_vehicle = await db.query('property_vehicles',
            where: "_id = '${property_vehicle["_id"]}'", limit: 1);

        // Convert to sqlite table format
        Map<String, dynamic> property_vehicleSqlite = {
          '_id': property_vehicle["_id"],
          'color': property_vehicle["color"],
          'fk_vehicle_id': property_vehicle["fk_vehicle_id"],
          'fk_property_id': property_vehicle["fk_property_id"],
          'createdAt': property_vehicle["created_at"],
          'updatedAt': property_vehicle["updated_at"],
        };

        // If entity is in the database, do the update
        if (current_property_vehicle.length > 0) {
          await db.update(
            'property_vehicles',
            property_vehicleSqlite,
            where: "_id = '${current_property_vehicle[0]["_id"]}'",
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } else {
          // Do insert
          await db.insert(
            'property_vehicles',
            property_vehicleSqlite,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      for (var del in deleted) {
        await db.rawDelete(
            "DELETE FROM property_vehicles WHERE _id = ?", [del["deleted_id"]]);
      }

      return true;
    } catch ($e) {
      throw $e;
    }
  }

  if (jsonDecode(response.body).containsKey("status") &&
      jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return receiveNewPropertyVehicleData(db);
  }

  throw Exception("Request error");
}

sendNewPropertyVehicleData(db) async {
  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  // Check if database has updated
  var updates = await db.query(
    'database_updates',
    where: "reference_table = 'property_vehicles'",
  );

  List<Map> property_vehicleChanges = [];

  for (var update in updates) {
    List<Map> property_vehicles = await db.query(
      'property_vehicles',
      where: "_id = '${update["updated_id"]}'",
      limit: 1,
    );

    Map property_vehicle = property_vehicles[0];

    property_vehicleChanges.add(property_vehicle);
  }

  // Check if database has deleted
  var deleted = await db.query(
    'garbages',
    where: "reference_table = 'property_vehicles'",
  );

  List propertyVehiclesDeleted = [];

  for (var del in deleted) {
    propertyVehiclesDeleted.add(del["deleted_id"]);
  }

  var allChanges = {
    'property_vehicles': property_vehicleChanges,
    'deleted': propertyVehiclesDeleted
  };

  String property_vehiclesJson = jsonEncode(allChanges);

  String uri =
      "http://ec2-107-21-160-174.compute-1.amazonaws.com:8002/api/sync/property-vehicles";
  final response = await http.post(Uri.parse(uri),
      headers: {
        "Authorization": "Bearer ${token}",
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: property_vehiclesJson);

  if (jsonDecode(response.body).containsKey("status") &&
      jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return sendNewPropertyVehicleData(db);
  }

  if (response.statusCode == 201 &&
      jsonDecode(response.body).containsKey("updated")) {
    await db.rawDelete(
        "DELETE FROM database_updates WHERE reference_table = 'property_vehicles'");

    await db.rawDelete(
        "DELETE FROM garbages WHERE reference_table = 'property_vehicles'");

    return true;
  }

  throw Exception("Não foi possível sincronizar os veículos");
}
