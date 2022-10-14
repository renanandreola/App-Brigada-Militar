import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/models/User.dart';
import 'package:app_brigada_militar/home.dart';
import 'package:app_brigada_militar/sync.dart';
import 'package:flutter/material.dart';
import 'initialPage.dart';

void main(List<String> args) {
  // Test commands before start application
  // debugDatabaseBeforeApp();

  runApp(MaterialApp(
    home: InitialPage(),
    debugShowCheckedModeBanner: false,
  ));
}

void debugDatabaseBeforeApp() async {
  // var renan = new User(email: "renan@gmail.com", password: "senhateste123", name: "Renan Andreolla");
  // var marlon = new User(email: "marlon@gmail.com", password: "senhateste123", name: "Marlon Angonese");
  // var rodrigo = new User(email: "rodrigo@gmail.com", password: "senhateste123", name: "Rodrigo Muntini");

  // await renan.save();
  // await marlon.save();
  // await rodrigo.save();

  // print("Usuário salvo!");

  final db = await DB.instance.database;

  var users = await UsersTable().find(email: "renan@gmail.com");
  var userrenan = users[0];
  users = await UsersTable().find(email: "marlon@gmail.com");
  var usermarlon = users[0];

  await db.insert("garbages", {
    'reference_table': 'users',
    'deleted_id': usermarlon.id,
  });
  usermarlon.delete();
}
