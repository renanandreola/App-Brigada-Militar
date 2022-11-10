import 'package:app_brigada_militar/initialPage.dart';
import 'package:flutter/material.dart';

void main(List<String> args) async {
  // Test commands before start application
  // debugDatabaseBeforeApp();

  runApp(MaterialApp(
    home: InitialPage(),
    debugShowCheckedModeBanner: false,
  ));
}

void debugDatabaseBeforeApp() async {
  
}
