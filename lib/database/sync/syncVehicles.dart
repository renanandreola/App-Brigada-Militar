import 'dart:convert';
import 'package:app_brigada_militar/database/sync/apiToken.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

Future<String?> syncVehicles () async {

  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  String uri = "https://novorumo-api.fly.dev/api/sync/vehicles";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    
    String query = "INSERT INTO vehicles (_id, name, brand, createdAt, updatedAt) VALUES";

    var vehicles = jsonDecode(response.body);

    try {
      for (var vehicle in vehicles) {
        String queryInsertLine = "\n('${vehicle["_id"].replaceAll("'", "''")}', '${vehicle["name"].replaceAll("'", "''")}', '${vehicle["brand"].replaceAll("'", "''")}', '${vehicle["created_at"].replaceAll("'", "''")}', '${vehicle["updated_at"].replaceAll("'", "''")}'),";

        query += queryInsertLine;
      }

      if (vehicles.length > 0) {
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
    return syncVehicles();
  }

  throw Exception("Request error");
}

updateVehicles(db) async {
  await sendNewVehicleData(db);
  // await receiveNewVehicleData(db);
}

receiveNewVehicleData(db) async {
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

  String uri = "https://novorumo-api.fly.dev/api/sync/vehicles?last_date=${lastSyncDate}";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    String query = "INSERT INTO vehicles (_id, name, brand, createdAt, updatedAt) VALUES";

    var responseBody = jsonDecode(response.body);
    var vehicles = responseBody["vehicles"];
    var deleted = responseBody["deleted"];

    try {
      for (var vehicle in vehicles) {
        // Check if entity is in the Sqlite database
        var current_vehicle = await db.query(
          'vehicles',
          where: "_id = '${vehicle["_id"]}'",
          limit: 1
        );

        // Convert to sqlite table format
        Map<String, dynamic> vehicleSqlite = {
          '_id': vehicle["_id"],
          'name':  vehicle["name"],
          'brand': vehicle["brand"],
          'createdAt': vehicle["created_at"],
          'updatedAt': vehicle["updated_at"],
        };

        // If entity is in the database, do the update
        if (current_vehicle.length > 0) {

          await db.update(
            'vehicles',
            vehicleSqlite,
            where: "_id = '${current_vehicle[0]["_id"]}'",
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

        } else { // Do insert
          await db.insert(
            'vehicles',
            vehicleSqlite,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }


      for (var del in deleted) {
        var current_vehicle = await db.query(
          'vehicles',
          where: "_id = '${del["_id"]}'",
          limit: 1
        );

        if (current_vehicle.length > 0) {
          await db.delete(
            'vehicles',
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
    return receiveNewVehicleData(db);
  }

  throw Exception("Request error");
}

sendNewVehicleData(db) async {
  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  // Check if database has updated
  var updates = await db.query(
    'database_updates',
    where: "reference_table = 'vehicles'",
  );

  List<Map> vehicleChanges = [];

  for (var update in updates) {
    List<Map> vehicles = await db.query(
      'vehicles',
      where: "_id = '${update["updated_id"]}'",
      limit: 1,
    );

    Map vehicle = vehicles[0];

    vehicleChanges.add(vehicle);
  }

  var allChanges = {'vehicles': vehicleChanges };

  String vehiclesJson = jsonEncode(allChanges);

  String uri = "https://novorumo-api.fly.dev/api/sync/vehicles";
  final response = await http.post(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}", "Content-Type": "application/json", "Accept": "application/json" }, body: vehiclesJson);

  if (jsonDecode(response.body).containsKey("status") && jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return sendNewVehicleData(db);
  }

  if (response.statusCode == 201 && jsonDecode(response.body).containsKey("updated")) {
    await db.rawDelete("DELETE FROM database_updates WHERE reference_table = 'vehicles'");
  
    return true;
  }

  throw Exception("Não foi possível sincronizar os veículos");
}