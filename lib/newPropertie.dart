import 'package:flutter/material.dart';

class NewPropertie extends StatefulWidget {
  const NewPropertie({Key? key}) : super(key: key);

  @override
  State<NewPropertie> createState() => _NewPropertieState();
}

class _NewPropertieState extends State<NewPropertie> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Nova propriedade"),
    );
  }
}
