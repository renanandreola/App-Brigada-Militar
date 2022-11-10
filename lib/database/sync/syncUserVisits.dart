import 'dart:convert';
import 'package:app_brigada_militar/database/sync/apiToken.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

Future<String?> syncUserVisits () async {

  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  String uri = "https://novo-rumo-api.herokuapp.com/api/sync/user-visits";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    
    String query = "INSERT INTO user_visits (_id, fk_visit_id, fk_user_id, createdAt, updatedAt) VALUES";

    var user_visits = jsonDecode(response.body);

    try {
      for (var user_visit in user_visits) {
        String queryInsertLine = "\n('${user_visit["_id"].replaceAll("'", "''")}', '${user_visit["fk_visit_id"].replaceAll("'", "''")}', '${user_visit["fk_user_id"].replaceAll("'", "''")}', '${user_visit["created_at"].replaceAll("'", "''")}', '${user_visit["updated_at"].replaceAll("'", "''")}'),";

        query += queryInsertLine;
      }

      if (user_visits.length > 0) {
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
    return syncUserVisits();
  }

  throw Exception("Request error");
}

updateUserVisits(db) async {
  await sendNewUserVisitData(db);
  await receiveNewUserVisitData(db);
}

receiveNewUserVisitData(db) async {
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

  String uri = "https://novo-rumo-api.herokuapp.com/api/sync/user-visits?last_date=${lastSyncDate}";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    String query = "INSERT INTO user_visits (_id, fk_visit_id, fk_user_id, createdAt, updatedAt) VALUES";

    var responseBody = jsonDecode(response.body);
    var user_visits = responseBody["user_visits"];
    var deleted = responseBody["deleted"];

    try {
      for (var user_visit in user_visits) {
        // Check if entity is in the Sqlite database
        var current_user_visit = await db.query(
          'user_visits',
          where: "_id = '${user_visit["_id"]}'",
          limit: 1
        );

        // Convert to sqlite table format
        Map<String, dynamic> user_visitSqlite = {
          '_id': user_visit["_id"],
          'fk_visit_id':  user_visit["fk_visit_id"],
          'fk_user_id': user_visit["fk_user_id"],
          'createdAt': user_visit["created_at"],
          'updatedAt': user_visit["updated_at"],
        };

        // If entity is in the database, do the update
        if (current_user_visit.length > 0) {

          await db.update(
            'user_visits',
            user_visitSqlite,
            where: "_id = '${current_user_visit[0]["_id"]}'",
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

        } else { // Do insert
          await db.insert(
            'user_visits',
            user_visitSqlite,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }


      for (var del in deleted) {
        var current_user_visit = await db.query(
          'user_visits',
          where: "_id = '${del["_id"]}'",
          limit: 1
        );

        if (current_user_visit.length > 0) {
          await db.delete(
            'user_visits',
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
    return receiveNewUserVisitData(db);
  }

  throw Exception("Request error");
}

sendNewUserVisitData(db) async {
  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  // Check if database has updated
  var updates = await db.query(
    'database_updates',
    where: "reference_table = 'user_visits'",
  );

  List<Map> user_visitChanges = [];

  for (var update in updates) {
    List<Map> user_visits = await db.query(
      'user_visits',
      where: "_id = '${update["updated_id"]}'",
      limit: 1,
    );

    Map user_visit = user_visits[0];

    user_visitChanges.add(user_visit);
  }

  var allChanges = {'user_visits': user_visitChanges };

  String user_visitsJson = jsonEncode(allChanges);

  String uri = "http://novo-rumo-api.herokuapp.com/api/sync/user-visits";
  final response = await http.post(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}", "Content-Type": "application/json", "Accept": "application/json" }, body: user_visitsJson);

  if (jsonDecode(response.body) is Map && jsonDecode(response.body).containsKey("status") && jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return sendNewUserVisitData(db);
  }

  if (response.statusCode == 200 || (response.statusCode == 201 && jsonDecode(response.body).containsKey("updated"))) {
    await db.rawDelete("DELETE FROM database_updates WHERE reference_table = 'user_visits'");
  
    return true;
  }

  throw Exception("Não foi possível sincronizar as Visitas dos");
}