import 'dart:convert';
import 'package:app_brigada_militar/database/sync/apiToken.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

Future<String?> syncRequests () async {

  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  String uri = "https://novo-rumo-api.herokuapp.com/api/sync/requests";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    
    String query = "INSERT INTO requests (_id, agency, has_success, fk_property_id, createdAt, updatedAt) VALUES";

    var requests = jsonDecode(response.body);

    try {
      for (var request in requests) {
        String queryInsertLine = "\n('${request["_id"].replaceAll("'", "''")}', '${request["agency"].replaceAll("'", "''")}', '${request["has_success"]}', '${request["fk_property_id"].replaceAll("'", "''")}', '${request["created_at"].replaceAll("'", "''")}', '${request["updated_at"].replaceAll("'", "''")}'),";

        query += queryInsertLine;
      }

      if (requests.length > 0) {
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
    return syncRequests();
  }

  throw Exception("Request error");
}

updateRequests(db) async {
  await sendNewRequestData(db);
  await receiveNewRequestData(db);
}

receiveNewRequestData(db) async {
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

  String uri = "https://novo-rumo-api.herokuapp.com/api/sync/requests?last_date=${lastSyncDate}";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    String query = "INSERT INTO requests (_id, agency, has_success, fk_property_id, createdAt, updatedAt) VALUES";

    var responseBody = jsonDecode(response.body);
    var requests = responseBody["requests"];
    var deleted = responseBody["deleted"];

    try {
      for (var request in requests) {
        // Check if entity is in the Sqlite database
        var current_request = await db.query(
          'requests',
          where: "_id = '${request["_id"]}'",
          limit: 1
        );

        // Convert to sqlite table format
        Map<String, dynamic> requestSqlite = {
          '_id': request["_id"],
          'agency':  request["agency"],
          'has_success': request["has_success"],
          'fk_property_id': request["fk_property_id"],
          'createdAt': request["created_at"],
          'updatedAt': request["updated_at"],
        };

        // If entity is in the database, do the update
        if (current_request.length > 0) {

          await db.update(
            'requests',
            requestSqlite,
            where: "_id = '${current_request[0]["_id"]}'",
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

        } else { // Do insert
          await db.insert(
            'requests',
            requestSqlite,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }


      for (var del in deleted) {
        var current_request = await db.query(
          'requests',
          where: "_id = '${del["_id"]}'",
          limit: 1
        );

        if (current_request.length > 0) {
          await db.delete(
            'requests',
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
    return receiveNewRequestData(db);
  }

  throw Exception("Request error");
}

sendNewRequestData(db) async {
  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  // Check if database has updated
  var updates = await db.query(
    'database_updates',
    where: "reference_table = 'requests'",
  );

  List<Map> requestChanges = [];

  for (var update in updates) {
    List<Map> requests = await db.query(
      'requests',
      where: "_id = '${update["updated_id"]}'",
      limit: 1,
    );

    Map request = requests[0];

    requestChanges.add(request);
  }

  var allChanges = {'requests': requestChanges };

  String requestsJson = jsonEncode(allChanges);

  String uri = "http://novo-rumo-api.herokuapp.com/api/sync/requests";
  final response = await http.post(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}", "Content-Type": "application/json", "Accept": "application/json" }, body: requestsJson);

  if (jsonDecode(response.body).containsKey("status") && jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return sendNewRequestData(db);
  }

  if (response.statusCode == 201 && jsonDecode(response.body).containsKey("updated")) {
    await db.rawDelete("DELETE FROM database_updates WHERE reference_table = 'requests'");
  
    return true;
  }

  throw Exception("Não foi possível sincronizar os veículos");
}