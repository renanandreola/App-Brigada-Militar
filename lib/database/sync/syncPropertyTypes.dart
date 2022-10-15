import 'dart:convert';
import 'package:app_brigada_militar/database/sync/apiToken.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

Future<String?> syncPropertyTypes () async {

  var token = await getToken();

  if (token == null) {
    throw Exception("Token is empty");
  }

  String uri = "https://novo-rumo-api.herokuapp.com/api/sync/property-types";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    
    String query = "INSERT INTO property_types (_id, name, createdAt, updatedAt) VALUES";

    var propertyTypes = jsonDecode(response.body);

    try {
      for (var propertyType in propertyTypes) {
        String queryInsertLine = "\n('${propertyType["_id"].replaceAll("'", "''")}', '${propertyType["name"].replaceAll("'", "''")}', '${propertyType["created_at"].replaceAll("'", "''")}', '${propertyType["updated_at"].replaceAll("'", "''")}'),";

        query += queryInsertLine;
      }

      if (propertyTypes.length > 0) {
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
    return syncPropertyTypes();
  }

  throw Exception("Request error");
}

updatePropertyTypes(db) async {
  await receiveNewPropertyTypeData(db);
}

receiveNewPropertyTypeData(db) async {
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

  String uri = "https://novo-rumo-api.herokuapp.com/api/sync/property-types?last_date=${lastSyncDate}";
  final response = await http.get(Uri.parse(uri), headers: { "Authorization": "Bearer ${token}" });

  if (response.statusCode == 200) {
    String query = "INSERT INTO property_types (_id, name, createdAt, updatedAt) VALUES";

    var responseBody = jsonDecode(response.body);
    var propertyTypes = responseBody["propertyTypes"];
    var deleted = responseBody["deleted"];

    try {
      for (var propertyType in propertyTypes) {
        // Check if entity is in the Sqlite database
        var current_property_type = await db.query(
          'property_types',
          where: "_id = '${propertyTypes["_id"]}'",
          limit: 1
        );

        // Convert to sqlite table format
        Map<String, dynamic> propertyTypeSqlite = {
          '_id': propertyType["_id"],
          'name':  propertyType["name"],
          'createdAt': propertyType["created_at"],
          'updatedAt': propertyType["updated_at"],
        };

        // If entity is in the database, do the update
        if (current_property_type.length > 0) {

          await db.update(
            'property_types',
            propertyTypeSqlite,
            where: "_id = '${current_property_type[0]["_id"]}'",
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

        } else { // Do insert
          await db.insert(
            'property_types',
            propertyTypeSqlite,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }


      for (var del in deleted) {
        var current_property_type = await db.query(
          'property_types',
          where: "_id = '${del["_id"]}'",
          limit: 1
        );

        if (current_property_type.length > 0) {
          await db.delete(
            'property_types',
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
    return receiveNewPropertyTypeData(db);
  }

  throw Exception("Request error");
}