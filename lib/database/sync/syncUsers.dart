import 'dart:convert';
import 'package:app_brigada_militar/database/sync/apiToken.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

Future<String?> syncUsers () async {

  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  String uri = "https://novorumo-api.fly.dev/api/sync/users";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    
    String query = "INSERT INTO users (_id, name, email, password, createdAt, updatedAt) VALUES";

    var users = jsonDecode(response.body);

    try {
      for (var user in users) {
        String queryInsertLine = "\n('${user["_id"].replaceAll("'", "''")}', '${user["name"].replaceAll("'", "''")}', '${user["email"].replaceAll("'", "''")}', '${user["password"].replaceAll("'", "''")}', '${user["created_at"].replaceAll("'", "''")}', '${user["updated_at"].replaceAll("'", "''")}'),";

        query += queryInsertLine;
      }

      if (users.length > 0) {
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
    return syncUsers();
  }

  throw Exception("Request error");
}

updateUsers(db) async {
  await sendNewUserData(db);
  // await receiveNewUserData(db);
}

receiveNewUserData(db) async {
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

  String uri = "https://novorumo-api.fly.dev/api/sync/users?last_date=${lastSyncDate}";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    String query = "INSERT INTO users (_id, name, email, password, createdAt, updatedAt) VALUES";

    var responseBody = jsonDecode(response.body);
    var users = responseBody["users"];
    var deleted = responseBody["deleted"];

    try {
      for (var user in users) {
        // Check if entity is in the Sqlite database
        var current_user = await db.query(
          'users',
          where: "_id = '${user["_id"]}'",
          limit: 1
        );

        // Convert to sqlite table format
        Map<String, dynamic> userSqlite = {
          '_id': user["_id"],
          'name':  user["name"],
          'email': user["email"],
          'password': user["password"],
          'createdAt': user["created_at"],
          'updatedAt': user["updated_at"],
        };

        // If entity is in the database, do the update
        if (current_user.length > 0) {

          await db.update(
            'users',
            userSqlite,
            where: "_id = '${current_user[0]["_id"]}'",
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

        } else { // Do insert
          await db.insert(
            'users',
            userSqlite,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }


      for (var del in deleted) {
        var current_user = await db.query(
          'users',
          where: "_id = '${del["_id"]}'",
          limit: 1
        );

        if (current_user.length > 0) {
          await db.delete(
            'users',
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
    return receiveNewUserData(db);
  }

  throw Exception("Request error");
}

sendNewUserData(db) async {
  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  // Check if database has updated
  var updates = await db.query(
    'database_updates',
    where: "reference_table = 'users'",
  );

  List<Map> userChanges = [];

  for (var update in updates) {
    List<Map> users = await db.query(
      'users',
      where: "_id = '${update["updated_id"]}'",
      limit: 1,
    );

    Map user = users[0];

    userChanges.add(user);
  }

  // Check if database has deleted
  var deleted = await db.query(
    'garbages',
    where: "reference_table = 'users'",
  );

  List userDeletes = [];

  for (var del in deleted) {
    userDeletes.add(del["deleted_id"]);
  }

  var allChanges = {'users': userChanges, 'deleted': userDeletes };

  String usersJson = jsonEncode(allChanges);

  String uri = "https://novorumo-api.fly.dev/api/sync/users";
  final response = await http.post(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}", "Content-Type": "application/json", "Accept": "application/json" }, body: usersJson);

  if (jsonDecode(response.body).containsKey("status") && jsonDecode(response.body)["status"] == "Token is Expired") {
    await generateToken();
    return sendNewUserData(db);
  }

  if (response.statusCode == 201 && jsonDecode(response.body).containsKey("updated")) {
    await db.rawDelete("DELETE FROM database_updates WHERE reference_table = 'users'");
    await db.rawDelete("DELETE FROM garbages WHERE reference_table = 'users'");
  
    return true;
  }

  throw Exception("Não foi possível sincronizar os usuários");
}