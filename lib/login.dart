import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var _welcomeText = "Bem-vindo!";
  var _welcomeSugestion = "Por favor, prossiga com seu login";
  var _forgotPassword = "Esqueci minha senha";
  var _loginText = "Login";

  void _voidForgotPassword() {
    print("Esqueci minha senha");
  }

  void _voidLogin() {
    print("Realizar login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.asset("assets/images/head.png"),
          // WELCOME TEXT
          Padding(
            padding: EdgeInsets.only(left: 0, top: 0),
            child: Text(
              _welcomeText,
              style: const TextStyle(
                  fontSize: 36,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontFamily: "RobotoFlex"),
            ),
          ),
          // SECOND WELCOME TEXT
          Padding(
            padding: EdgeInsets.only(left: 0),
            child: Text(
              _welcomeSugestion,
              style: const TextStyle(
                  fontSize: 24,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.normal,
                  fontFamily: "RobotoFlex"),
            ),
          ),
          // EMAIL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'user123@eail.com',
              ),
            ),
          ),
          // PASSWORD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'user123@eail.com',
              ),
            ),
          ),
          // FORGOT PASSWORD
          GestureDetector(
            onTap: _voidForgotPassword,
            child: Text(
              _forgotPassword,
              style: const TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.normal,
                  fontFamily: "RobotoFlex"),
            ),
          ),
          // LOGIN
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 32, 90, 33), elevation: 2),
              onPressed: _voidLogin,
              child: Text(
                _loginText,
                style: TextStyle(fontSize: 25),
              ))
        ],
      ),
    );
  }
}
