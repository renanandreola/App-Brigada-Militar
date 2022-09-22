import 'package:flutter/material.dart';
import 'initialPage.dart';

void main(List<String> args) {
  // Test commands before start application
  debugDatabaseBeforeApp();

  runApp(MaterialApp(
    home: InitialPage(),
    debugShowCheckedModeBanner: false,
  ));
}

void debugDatabaseBeforeApp() async {}
