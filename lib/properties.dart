import 'package:flutter/material.dart';

class Properties extends StatefulWidget {
  const Properties({Key? key}) : super(key: key);

  @override
  State<Properties> createState() => _PropertiesState();
}

class _PropertiesState extends State<Properties> {
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
                  child: Text("Propriedadaes",
                      style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          fontFamily: "RobotoFlex"))),
            ],
          ),
        ),
      )),
    );
  }
}
