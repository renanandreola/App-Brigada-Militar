import 'dart:convert';
import 'package:app_brigada_militar/database/sync/apiToken.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

Future<String?> syncAgriculturalMachines () async {

  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  String uri = "https://novorumo-api.fly.dev/api/sync/agricultural-machines";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    
    String query = "INSERT INTO agricultural_machines (_id, name, createdAt, updatedAt) VALUES";

    var agricultural_machines = jsonDecode(response.body);

    try {
      for (var agricultural_machine in agricultural_machines) {
        String queryInsertLine = "\n('${agricultural_machine["_id"].replaceAll("'", "''")}', '${agricultural_machine["name"].replaceAll("'", "''")}', '${agricultural_machine["created_at"].replaceAll("'", "''")}', '${agricultural_machine["updated_at"].replaceAll("'", "''")}'),";

        query += queryInsertLine;
      }

      if (agricultural_machines.length > 0) {
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
    return syncAgriculturalMachines();
  }

  throw Exception("Request error");
}

updateAgriculturalMachines(db) async {
  await sendNewAgriculturalMachineData(db);
  // await receiveNewAgriculturalMachineData(db);
}

receiveNewAgriculturalMachineData(db) async {
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

  String uri = "https://novorumo-api.fly.dev/api/sync/agricultural-machines?last_date=${lastSyncDate}";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    String query = "INSERT INTO agricultural_machines (_id, name, createdAt, updatedAt) VALUES";

    var responseBody = jsonDecode(response.body);
    var agricultural_machines = responseBody["agricultural_machines"];
    var deleted = responseBody["deleted"];

    try {
      for (var agricultural_machine in agricultural_machines) {
        // Check if entity is in the Sqlite database
        var current_agricultural_machine = await db.query(
          'agricultural_machines',
          where: "_id = '${agricultural_machine["_id"]}'",
          limit: 1
        );

        // Convert to sqlite table format
        Map<String, dynamic> agricultural_machineSqlite = {
          '_id': agricultural_machine["_id"],
          'name':  agricultural_machine["name"],
          'createdAt': agricultural_machine["created_at"],
          'updatedAt': agricultural_machine["updated_at"],
        };

        // If entity is in the database, do the update
        if (current_agricultural_machine.length > 0) {

          await db.update(
            'agricultural_machines',
            agricultural_machineSqlite,
            where: "_id = '${current_agricultural_machine[0]["_id"]}'",
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

        } else { // Do insert
          await db.insert(
            'agricultural_machines',
            agricultural_machineSqlite,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }


      for (var del in deleted) {
        var current_agricultural_machine = await db.query(
          'agricultural_machines',
          where: "_id = '${del["_id"]}'",
          limit: 1
        );

        if (current_agricultural_machine.length > 0) {
          await db.delete(
            'agricultural_machines',
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
    return receiveNewAgriculturalMachineData(db);
  }

  throw Exception("Request error");
}

sendNewAgriculturalMachineData(db) async {
  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  // Check if database has updated
  var updates = await db.query(
    'database_updates',
    where: "reference_table = 'agricultural_machines'",
  );

  List<Map> agricultural_machineChanges = [];

  for (var update in updates) {
    List<Map> agricultural_machines = await db.query(
      'agricultural_machines',
      where: "_id = '${update["updated_id"]}'",
      limit: 1,
    );

    Map agricultural_machine = agricultural_machines[0];

    agricultural_machineChanges.add(agricultural_machine);
  }

  var allChanges = {'agricultural_machines': agricultural_machineChanges };

  String agricultural_machinesJson = jsonEncode(allChanges);

  String uri = "https://novorumo-api.fly.dev/api/sync/agricultural-machines";
  final response = await http.post(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}", "Content-Type": "application/json", "Accept": "application/json" }, body: agricultural_machinesJson);

  if (jsonDecode(response.body).containsKey("status") && jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return sendNewAgriculturalMachineData(db);
  }

  if (response.statusCode == 201 && jsonDecode(response.body).containsKey("updated")) {
    await db.rawDelete("DELETE FROM database_updates WHERE reference_table = 'agricultural_machines'");
  
    return true;
  }

  throw Exception("Não foi possível sincronizar os veículos");
}