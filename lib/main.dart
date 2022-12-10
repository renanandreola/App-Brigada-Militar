import 'dart:developer';

import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/initialPage.dart';
import 'package:app_brigada_militar/updateinitial.dart';
import 'package:app_brigada_militar/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

void main(List<String> args) async {
  // Test commands before start application
  // debugDatabaseBeforeApp();
  runApp(MaterialApp(
    home: UpdateInitial(),
    debugShowCheckedModeBanner: false,
  ));
}

void debugDatabaseBeforeApp() async {
  
}
