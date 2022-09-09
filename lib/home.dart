import 'package:flutter/material.dart';
import 'package:app_brigada_militar/configuration.dart';
import 'package:app_brigada_militar/editProperties.dart';
import 'package:app_brigada_militar/newPropertie.dart';
import 'package:app_brigada_militar/properties.dart';
import 'package:app_brigada_militar/sync.dart';
import 'package:app_brigada_militar/update7waysMenu.dart';

class HomeApp extends StatefulWidget {
  // const HomeApp({Key? key}) : super(key: key);
  late String userName;
  HomeApp(this.userName);

  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  void _openProperties() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Properties()));
  }

  void _editPropertie() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => EditProperties()));
  }

  void _newPropertie() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NewPropertie()));
  }

  void _openSync() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Sync()));
  }

  void _update7ways() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Update7waysMenu()));
  }

  void _openConfiguration() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Configuration()));
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
                        child: Image.asset('assets/images/propriedades.png'),
                        onTap: _openProperties,
                      ),
                      GestureDetector(
                        child:
                            Image.asset('assets/images/editar-propriedade.png'),
                        onTap: _editPropertie,
                      )
                    ]),
              ),

              // Image 3 and 4
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child:
                            Image.asset('assets/images/nova-propriedade.png'),
                        onTap: _newPropertie,
                      ),
                      GestureDetector(
                        child: Image.asset('assets/images/sincronizar.png'),
                        onTap: _openSync,
                      )
                    ]),
              ),

              // Image 5 and 6
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child:
                            Image.asset('assets/images/atualizacao-7ways.png'),
                        onTap: _update7ways,
                      ),
                      GestureDetector(
                        child: Image.asset('assets/images/configuracao.png'),
                        onTap: _openConfiguration,
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
