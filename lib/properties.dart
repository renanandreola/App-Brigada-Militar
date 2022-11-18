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
      title: new Center(
          child: new Text(
        "Propriedades",
        textAlign: TextAlign.center,
      )),
      backgroundColor: Color.fromARGB(255, 27, 75, 27),
    ));
  }
}
