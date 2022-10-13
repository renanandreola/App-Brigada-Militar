import 'package:app_brigada_militar/database/sync/apiToken.dart';
import 'package:app_brigada_militar/database/sync/syncUsers.dart';
import 'package:flutter/material.dart';
import 'package:app_brigada_militar/update7ways.dart';
import 'package:app_brigada_militar/login.dart';
import 'database/db.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final db = DB.instance.database;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _goToLoginPage() {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Entrando...')),
    // );
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  }

  void _goToUpdate() {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Entrando...')),
    // );
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Update7ways()));
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

            // Novo Rumo
            Padding(
              padding: EdgeInsets.only(left: 0, right: 0, top: 15),
              child: Image.asset('assets/images/logo-novo-rumo.png'),
            ),

            // Welcome Text 1
            Padding(
              padding: EdgeInsets.only(left: 32, right: 32, top: 5),
              child: Text(
                'NOVO RUMO',
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 30,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    fontFamily: "RobotoFlex"),
              ),
            ),

            // Login
            Padding(
              padding: EdgeInsets.only(left: 32, right: 32, top: 35),
              child: ElevatedButton(
                child: Text(
                  'Fazer Login',
                  style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600,
                      fontFamily: "RobotoFlex"),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 27, 75, 27),
                  elevation: 2,
                  fixedSize: Size(330, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _goToLoginPage,
              ),
            ),

            // Update 7ways
            Padding(
              padding: EdgeInsets.only(left: 32, right: 32, top: 25),
              child: ElevatedButton(
                child: Text(
                  'Atualizar 7ways',
                  style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600,
                      fontFamily: "RobotoFlex",
                      color: Color.fromARGB(255, 27, 75, 27)),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 255, 255, 255),
                  elevation: 2,
                  fixedSize: Size(330, 50),
                  side: BorderSide(
                      width: 2.0, color: Color.fromARGB(255, 27, 75, 27)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _goToUpdate,
              ),
            ),
          ]),
        ),
      ),
    ));
  }
}
