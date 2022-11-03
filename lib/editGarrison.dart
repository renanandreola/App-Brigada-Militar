import 'package:flutter/material.dart';

class EditGarrison extends StatefulWidget {
  // const EditGarrison({Key? key}) : super(key: key);
  late String userName;
  EditGarrison(this.userName);

  @override
  State<EditGarrison> createState() => _EditGarrisonState();
}

class _EditGarrisonState extends State<EditGarrison> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: new Center(
        //     child: new Text('NOVO RUMO', textAlign: TextAlign.center)),
        title: Text(
          "Editar Guarnição",
          textAlign: TextAlign.center,
        ),
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
            ],
          ),
        ),
      )),
    );
  }
}
