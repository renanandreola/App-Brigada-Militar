import 'dart:convert';

import 'package:app_brigada_militar/database/models/User.dart';
import 'package:app_brigada_militar/forgotPassword.dart';
import 'package:app_brigada_militar/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _forgotPassword() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ForgotPassword()));
  }

  void _voidLogin() async {
    // execute just on the first acess on database;
    // User new_user = new User(email: "renan@gmail.com", password: '123');
    // await new_user.save();
    // print(_email.text);
    // print(_password.text);

    // Will return true or false
    final response =
        await UsersTable().authenticate(_email.text, _password.text);
    if (response) {
      final users = await UsersTable().find(email: _email.text);
      User user = users[0];
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => HomeApp(user.name!)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login inválido')),
    );
  }

  // Future<http.Response> sendLogin(_email, _password) async {
  //   // var url = Uri.parse('bm-erechim-api.herokuapp.com/api/users/login');
  //   var response = await http.post(
  //     Uri.parse('https://bm-erechim-api.herokuapp.com/api/users/login'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'email': 'rodrigo@mucilon.com',
  //       'password': 'mucilon',
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     print("RENANN" + response.body);
  //     // return jsonDecode(utf8.decode(response.bodyBytes));
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception("Erro ao fazer login");
  //   }
  // }

  // Future<http.Response> pegarUsuarios() async {
  //   var url = Uri.parse('http://bm-erechim-api.herokuapp.com/api/users');
  //   var response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     print("RENANN" + response.body);
  //     return jsonDecode(utf8.decode(response.bodyBytes));
  //   } else {
  //     throw Exception("Erro ao carregar dados");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Container(
          // padding: EdgeInsets.all(16),
          child: Column(children: [
            // Image
            Padding(
              padding: EdgeInsets.only(top: 0, bottom: 16),
              child: Image.asset("assets/images/head.png"),
            ),

            // Welcome Text 1
            Padding(
              padding: EdgeInsets.only(left: 32, right: 32, top: 50),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'Bem-vindo!',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 30,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontFamily: "RobotoFlex"),
                ),
              ),
            ),

            // Welcome Text 2
            Padding(
              padding: EdgeInsets.only(left: 32, right: 32, top: 12),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'Por favor, prossiga com seu login',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      fontFamily: "RobotoFlex"),
                ),
              ),
            ),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    Padding(
                      padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Preencha seu e-mail';
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          labelText: "E-mail",
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 88, 88, 88),
                          ),
                          prefixIcon: Icon(Icons.email, color: Colors.black),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 88, 88, 88)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        controller: _email,
                      ),
                    ),

                    // Password
                    Padding(
                      padding: EdgeInsets.only(left: 32, right: 32, top: 15),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Preencha sua senha';
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          labelText: "Senha",
                          prefixIcon: Icon(Icons.lock, color: Colors.black),
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 88, 88, 88),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 88, 88, 88)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        controller: _password,
                      ),
                    ),

                    // Forgot Password
                    // Padding(
                    //   padding: EdgeInsets.only(left: 32, right: 32, top: 30),
                    //   child: GestureDetector(
                    //     onTap: _forgotPassword,
                    //     child: Text(
                    //       "Esqueci minha senha",
                    //       style: const TextStyle(
                    //           color: Color.fromARGB(255, 27, 75, 27),
                    //           fontSize: 18,
                    //           fontStyle: FontStyle.normal,
                    //           fontWeight: FontWeight.w400,
                    //           fontFamily: "RobotoFlex"),
                    //     ),
                    //   ),
                    // ),

                    // Login
                    Padding(
                      padding: EdgeInsets.only(left: 32, right: 32, top: 25),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 27, 75, 27),
                          elevation: 2,
                          fixedSize: Size(330, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30), // <-- Radius
                          ),
                        ),
                        onPressed: _voidLogin,
                        icon: Icon(
                          Icons.send,
                          size: 24.0,
                        ),
                        label: Text('Login',
                            style: TextStyle(fontSize: 20)), // <-- Text
                      ),
                    )
                  ],
                )),
          ]),
        ),
      ),
    ));
  }
}
