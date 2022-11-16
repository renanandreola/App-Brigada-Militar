import 'dart:convert';

import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;

/**
 * Catch current token
 * 
 * If token doesn't exists, generates a new one
 */
dynamic getToken() async {
  var session = SessionManager();

  dynamic token = await session.get('api-token');

  if (token == null) {
    return generateToken();
  }

  return token;
}

/**
 * Create a new API Token
 */
dynamic generateToken() async {
  String uri = "https://novorumo-api.fly.dev/api/auth/login";

  final response = await http.post(Uri.parse(uri), body: { "email": "tracey.gulgowski@hotmail.com", "password": "r`.o=rv*31v" });

  if (response.statusCode == 200) {
    var token = jsonDecode(response.body)["access_token"];

    var session = SessionManager();
    await session.set("api-token", token);

    return token;
  }

  return null;
}