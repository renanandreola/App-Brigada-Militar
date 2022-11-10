import 'dart:convert';
import 'package:app_brigada_militar/database/sync/apiToken.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

Future<String?> syncPropertyAgriculturalMachines () async {

  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  String uri = "https://novo-rumo-api.herokuapp.com/api/sync/property-agricultural-machines";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    
    String query = "INSERT INTO property_agricultural_machines (_id, fk_agricultural_machine_id, fk_property_id, createdAt, updatedAt) VALUES";

    var property_agricultural_machines = jsonDecode(response.body);

    try {
      for (var property_agricultural_machine in property_agricultural_machines) {
        String queryInsertLine = "\n('${property_agricultural_machine["_id"].replaceAll("'", "''")}', '${property_agricultural_machine["fk_agricultural_machine_id"].replaceAll("'", "''")}', '${property_agricultural_machine["fk_property_id"].replaceAll("'", "''")}', '${property_agricultural_machine["created_at"].replaceAll("'", "''")}', '${property_agricultural_machine["updated_at"].replaceAll("'", "''")}'),";

        query += queryInsertLine;
      }

      if (property_agricultural_machines.length > 0) {
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
    return syncPropertyAgriculturalMachines();
  }

  throw Exception("Request error");
}

updatePropertyAgriculturalMachines(db) async {
  await sendNewPropertyAgriculturalMachineData(db);
  await receiveNewPropertyAgriculturalMachineData(db);
}

receiveNewPropertyAgriculturalMachineData(db) async {
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

  String uri = "https://novo-rumo-api.herokuapp.com/api/sync/property-agricultural-machines?last_date=${lastSyncDate}";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    String query = "INSERT INTO property_agricultural_machines (_id, fk_agricultural_machine_id, fk_property_id, createdAt, updatedAt) VALUES";

    var responseBody = jsonDecode(response.body);
    var property_agricultural_machines = responseBody["property_agricultural_machines"];
    var deleted = responseBody["deleted"];

    try {
      for (var property_agricultural_machine in property_agricultural_machines) {
        // Check if entity is in the Sqlite database
        var current_property_agricultural_machine = await db.query(
          'property_agricultural_machines',
          where: "_id = '${property_agricultural_machine["_id"]}'",
          limit: 1
        );

        // Convert to sqlite table format
        Map<String, dynamic> property_agricultural_machineSqlite = {
          '_id': property_agricultural_machine["_id"],
          'fk_agricultural_machine_id': property_agricultural_machine["fk_agricultural_machine_id"],
          'fk_property_id': property_agricultural_machine["fk_property_id"],
          'createdAt': property_agricultural_machine["created_at"],
          'updatedAt': property_agricultural_machine["updated_at"],
        };

        // If entity is in the database, do the update
        if (current_property_agricultural_machine.length > 0) {

          await db.update(
            'property_agricultural_machines',
            property_agricultural_machineSqlite,
            where: "_id = '${current_property_agricultural_machine[0]["_id"]}'",
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

        } else { // Do insert
          await db.insert(
            'property_agricultural_machines',
            property_agricultural_machineSqlite,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }


      for (var del in deleted) {
        var current_property_agricultural_machine = await db.query(
          'property_agricultural_machines',
          where: "_id = '${del["_id"]}'",
          limit: 1
        );

        if (current_property_agricultural_machine.length > 0) {
          await db.delete(
            'property_agricultural_machines',
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
    return receiveNewPropertyAgriculturalMachineData(db);
  }

  throw Exception("Request error");
}

sendNewPropertyAgriculturalMachineData(db) async {
  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  // Check if database has updated
  var updates = await db.query(
    'database_updates',
    where: "reference_table = 'property_agricultural_machines'",
  );

  List<Map> property_agricultural_machineChanges = [];

  for (var update in updates) {
    List<Map> property_agricultural_machines = await db.query(
      'property_agricultural_machines',
      where: "_id = '${update["updated_id"]}'",
      limit: 1,
    );

    Map property_agricultural_machine = property_agricultural_machines[0];

    property_agricultural_machineChanges.add(property_agricultural_machine);
  }

  var allChanges = {'property_agricultural_machines': property_agricultural_machineChanges };

  String property_agricultural_machinesJson = jsonEncode(allChanges);

  String uri = "http://novo-rumo-api.herokuapp.com/api/sync/property-agricultural-machines";
  final response = await http.post(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}", "Content-Type": "application/json", "Accept": "application/json" }, body: property_agricultural_machinesJson);

  if (jsonDecode(response.body).containsKey("status") && jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return sendNewPropertyAgriculturalMachineData(db);
  }

  if (response.statusCode == 201 && jsonDecode(response.body).containsKey("updated")) {
    await db.rawDelete("DELETE FROM database_updates WHERE reference_table = 'property_agricultural_machines'");
  
    return true;
  }

  throw Exception("Não foi possível sincronizar os veículos");
}