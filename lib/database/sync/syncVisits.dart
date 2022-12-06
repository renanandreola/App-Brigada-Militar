import 'dart:convert';
import 'dart:developer';
import 'package:app_brigada_militar/database/sync/apiToken.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

Future<String?> syncVisits() async {
  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  String uri =
      "http://ec2-107-21-160-174.compute-1.amazonaws.com:8002/api/sync/visits";
  final response = await http
      .get(Uri.parse(uri), headers: {"Authorization": "Bearer ${token}"});

  if (response.statusCode == 200) {
    String query =
        "INSERT INTO visits (_id, car, date, fk_property_id, history, createdAt, updatedAt) VALUES";

    var visits = jsonDecode(response.body);

    try {
      for (var visit in visits) {
        visit["history"] = visit["history"] == null ? "" : visit["history"];
        String queryInsertLine =
            "\n('${visit["_id"].replaceAll("'", "''")}', '${visit["car"].replaceAll("'", "''")}', '${visit["date"].replaceAll("'", "''")}', '${visit["fk_property_id"].replaceAll("'", "''")}', '${visit["history"].replaceAll("'", "''")}', '${visit["created_at"].replaceAll("'", "''")}', '${visit["updated_at"].replaceAll("'", "''")}'),";

        query += queryInsertLine;
      }

      if (visits.length > 0) {
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
    return syncVisits();
  }

  throw Exception("Request error");
}

updateVisits(db) async {
  await sendNewVisitData(db);
  // await receiveNewVisitData(db);
}

receiveNewVisitData(db) async {
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
      "http://ec2-107-21-160-174.compute-1.amazonaws.com:8002/api/sync/visits?last_date=${lastSyncDate}";
  final response = await http
      .get(Uri.parse(uri), headers: {"Authorization": "Bearer ${token}"});

  if (response.statusCode == 200) {
    String query =
        "INSERT INTO visits (_id, car, date, fk_property_id, history, createdAt, updatedAt) VALUES";

    var responseBody = jsonDecode(response.body);
    var visits = responseBody["visits"];
    var deleted = responseBody["deleted"];

    try {
      for (var visit in visits) {
        // Check if entity is in the Sqlite database
        var current_visit = await db.query('visits',
            where: "_id = '${visit["_id"]}'", limit: 1);

        // Convert to sqlite table format
        Map<String, dynamic> visitSqlite = {
          '_id': visit["_id"],
          'car': visit["car"],
          'date': visit["date"],
          'fk_property_id': visit['fk_property_id'],
          'history': visit['history'],
          'createdAt': visit["created_at"],
          'updatedAt': visit["updated_at"],
        };

        // If entity is in the database, do the update
        if (current_visit.length > 0) {
          await db.update(
            'visits',
            visitSqlite,
            where: "_id = '${current_visit[0]["_id"]}'",
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } else {
          // Do insert
          await db.insert(
            'visits',
            visitSqlite,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      for (var del in deleted) {
        var current_visit =
            await db.query('visits', where: "_id = '${del["_id"]}'", limit: 1);

        if (current_visit.length > 0) {
          await db.delete(
            'visits',
            where: "_id = '${del["deleted_id"]}'",
          );
        }
      }

      return true;
    } catch ($e) {
      throw $e;
    }
  }

  if (jsonDecode(response.body).containsKey("status") &&
      jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return receiveNewVisitData(db);
  }

  throw Exception("Request error");
}

sendNewVisitData(db) async {
  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  // Check if database has updated
  var updates = await db.query(
    'database_updates',
    where: "reference_table = 'visits'",
  );

  List<Map> visitChanges = [];

  for (var update in updates) {
    List<Map> visits = await db.query(
      'visits',
      where: "_id = '${update["updated_id"]}'",
      limit: 1,
    );

    Map visit = visits[0];

    visitChanges.add(visit);
  }

  var allChanges = {'visits': visitChanges};

  String visitsJson = jsonEncode(allChanges);

  String uri =
      "http://ec2-107-21-160-174.compute-1.amazonaws.com:8002/api/sync/visits";
  final response = await http.post(Uri.parse(uri),
      headers: {
        "Authorization": "Bearer ${token}",
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: visitsJson);

  if (jsonDecode(response.body).containsKey("status") &&
      jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return sendNewVisitData(db);
  }

  inspect(jsonDecode(response.body));

  if (response.statusCode == 201 &&
      jsonDecode(response.body).containsKey("updated")) {
    await db.rawDelete(
        "DELETE FROM database_updates WHERE reference_table = 'visits'");

    return true;
  }

  throw Exception("Não foi possível sincronizar as visitas");
}
