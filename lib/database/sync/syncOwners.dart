import 'dart:convert';
import 'package:app_brigada_militar/database/sync/apiToken.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

Future<String?> syncOwners () async {

  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  String uri = "http://ec2-107-21-160-174.compute-1.amazonaws.com:8002/api/sync/owners";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    
    String query = "INSERT INTO owners (_id, firstname, lastname, cpf, phone1, phone2, createdAt, updatedAt) VALUES";

    var owners = jsonDecode(response.body);

    try {
      for (var owner in owners) {
        String queryInsertLine = "\n('${owner["_id"].replaceAll("'", "''")}', '${owner["firstname"].replaceAll("'", "''")}', '${owner["lastname"].replaceAll("'", "''")}', '${owner["cpf"].replaceAll("'", "''")}', '${owner["phone1"].replaceAll("'", "''")}', '${owner["phone2"].replaceAll("'", "''")}', '${owner["created_at"].replaceAll("'", "''")}', '${owner["updated_at"].replaceAll("'", "''")}'),";

        query += queryInsertLine;
      }

      if (owners.length > 0) {
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
    return syncOwners();
  }

  throw Exception("Request error");
}

updateOwners(db) async {
  await sendNewOwnerData(db);
  // await receiveNewOwnerData(db);
}

receiveNewOwnerData(db) async {
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

  String uri = "http://ec2-107-21-160-174.compute-1.amazonaws.com:8002/api/sync/owners?last_date=${lastSyncDate}";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    String query = "INSERT INTO owners (_id, firstname, lastname, cpf, phone1, phone2, createdAt, updatedAt) VALUES";

    var responseBody = jsonDecode(response.body);
    var owners = responseBody["owners"];
    var deleted = responseBody["deleted"];

    try {
      for (var owner in owners) {
        // Check if entity is in the Sqlite database
        var current_owner = await db.query(
          'owners',
          where: "_id = '${owner["_id"]}'",
          limit: 1
        );

        // Convert to sqlite table format
        Map<String, dynamic> ownerSqlite = {
          '_id': owner["_id"],
          'firstname':  owner["firstname"],
          'lastname': owner["lastname"],
          'cpf': owner["cpf"],
          'phone1': owner["phone1"],
          'phone2': owner["phone2"],
          'createdAt': owner["created_at"],
          'updatedAt': owner["updated_at"],
        };

        // If entity is in the database, do the update
        if (current_owner.length > 0) {

          await db.update(
            'owners',
            ownerSqlite,
            where: "_id = '${current_owner[0]["_id"]}'",
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

        } else { // Do insert
          await db.insert(
            'owners',
            ownerSqlite,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }


      for (var del in deleted) {
        var current_owner = await db.query(
          'owners',
          where: "_id = '${del["_id"]}'",
          limit: 1
        );

        if (current_owner.length > 0) {
          await db.delete(
            'owners',
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
    return receiveNewOwnerData(db);
  }

  throw Exception("Request error");
}

sendNewOwnerData(db) async {
  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  // Check if database has updated
  var updates = await db.query(
    'database_updates',
    where: "reference_table = 'owners'",
  );

  List<Map> ownerChanges = [];

  for (var update in updates) {
    List<Map> owners = await db.query(
      'owners',
      where: "_id = '${update["updated_id"]}'",
      limit: 1,
    );

    Map owner = owners[0];

    ownerChanges.add(owner);
  }

  // Check if database has deleted
  var deleted = await db.query(
    'garbages',
    where: "reference_table = 'owners'",
  );

  List ownerDeletes = [];

  for (var del in deleted) {
    ownerDeletes.add(del["deleted_id"]);
  }

  var allChanges = {'owners': ownerChanges, 'deleted': ownerDeletes };

  String ownersJson = jsonEncode(allChanges);

  String uri = "http://ec2-107-21-160-174.compute-1.amazonaws.com:8002/api/sync/owners";
  final response = await http.post(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}", "Content-Type": "application/json", "Accept": "application/json" }, body: ownersJson);

  if (jsonDecode(response.body).containsKey("status") && jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return sendNewOwnerData(db);
  }

  if (response.statusCode == 201 && jsonDecode(response.body).containsKey("updated")) {
    await db.rawDelete("DELETE FROM database_updates WHERE reference_table = 'owners'");
    await db.rawDelete("DELETE FROM garbages WHERE reference_table = 'owners'");
  
    return true;
  }

  throw Exception("Não foi possível sincronizar os proprietários");
}