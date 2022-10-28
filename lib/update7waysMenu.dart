import 'package:flutter/material.dart';

class Update7waysMenu extends StatefulWidget {
  const Update7waysMenu({Key? key}) : super(key: key);

  @override
  State<Update7waysMenu> createState() => _Update7waysMenuState();
}

class _Update7waysMenuState extends State<Update7waysMenu> {
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
                  child: Text("Atualizar 7 ways",
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
