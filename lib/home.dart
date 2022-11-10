import 'dart:developer';

import 'package:app_brigada_militar/editGarrison.dart';
import 'package:app_brigada_militar/garrison.dart';
import 'package:app_brigada_militar/newVisit.dart';
import 'package:app_brigada_militar/update7ways.dart';
import 'package:flutter/material.dart';
import 'package:app_brigada_militar/logout.dart';
import 'package:app_brigada_militar/newProperty.dart';
import 'package:app_brigada_militar/properties.dart';
import 'package:app_brigada_militar/sync.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class HomeApp extends StatefulWidget {
  // const HomeApp({Key? key}) : super(key: key);
  late String userName;
  HomeApp(this.userName);

  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    cleanSession();
  }

  cleanSession() async {
    //Vehicles
    await SessionManager().remove('vehicles');
    //AgriculturalMachines
    await SessionManager().remove('agricultural_machines');
    //Owner
    await SessionManager().remove('owner');
    //Edit Property
    await SessionManager().remove('edit_property');
    //Edit Owner
    await SessionManager().remove('edit_owner');
  }

  void _openProperties() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Properties()));
  }

  void _editGarrison() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => EditGarrison(widget.userName)));
  }

  // void _editPropertie() {
  //   Navigator.push(
  //       context, MaterialPageRoute(builder: (context) => EditProperties()));
  // }

  void _newVisit() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NewVisit()));
  }

  void _openSync() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Sync()));
  }

  void _update7ways() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Update7ways()));
  }

  void _openLogOut() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LogOut()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: new Center(
        //     child: new Text('NOVO RUMO', textAlign: TextAlign.center)),
        title: Text("NOVO RUMO"),
        backgroundColor: Color.fromARGB(255, 27, 75, 27),
        leading: GestureDetector(
          onTap: () {/* Write listener code here */},
          child: Icon(
            Icons.menu, // add custom icons also
          ),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              // Padding(
              //   padding: EdgeInsets.only(top: 0, bottom: 16),
              //   child: Container(
              //     width: double.infinity,
              //     color: Color.fromARGB(255, 27, 75, 27),
              //     child: Text("opa"),
              //   ),
              // ),
              Image.asset('assets/images/rectangle.png'),

              // User Name
              Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                  child: Row(
                    children: [
                      Text("Olá, ",
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.normal,
                              fontFamily: "RobotoFlex")),
                      Text(widget.userName,
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                              fontFamily: "RobotoFlex"))
                    ],
                  )),

              // Text info
              Padding(
                padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Escolha entre os serviços abaixo:',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.normal,
                        fontFamily: "RobotoFlex"),
                  ),
                ),
              ),

              // Image 1 and 2
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Image.asset('assets/images/new-icon-visit.png'),
                        onTap: _newVisit,
                      ),
                      GestureDetector(
                        child:
                            Image.asset('assets/images/new-icon-garrison.png'),
                        onTap: _editGarrison,
                      ),
                    ]),
              ),

              // Image 3 and 4
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Image.asset('assets/images/new-icon-sync.png'),
                        onTap: _openSync,
                      ),
                      GestureDetector(
                        child: Image.asset('assets/images/new-icon-7ways.png'),
                        onTap: _update7ways,
                      ),
                    ]),
              ),

              // Image 5 and 6
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Image.asset('assets/images/new-icon-logout.png'),
                        onTap: _openLogOut,
                      )
                    ]),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
