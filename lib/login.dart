import 'package:app_brigada_militar/forgotPassword.dart';
import 'package:app_brigada_militar/home.dart';
import 'package:flutter/material.dart';

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

  void _voidLogin() {
    String _nameUser = 'Renan Andreolla';
    if (_formKey.currentState!.validate()) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Entrando...')),
      // );
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeApp(_nameUser)));
    }
  }

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
                    Padding(
                      padding: EdgeInsets.only(left: 32, right: 32, top: 30),
                      child: GestureDetector(
                        onTap: _forgotPassword,
                        child: Text(
                          "Esqueci minha senha",
                          style: const TextStyle(
                              color: Color.fromARGB(255, 27, 75, 27),
                              fontSize: 18,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w400,
                              fontFamily: "RobotoFlex"),
                        ),
                      ),
                    ),

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
