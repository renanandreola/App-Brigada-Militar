import 'package:flutter/material.dart';

class EditProperties extends StatefulWidget {
  const EditProperties({Key? key}) : super(key: key);

  @override
  State<EditProperties> createState() => _EditPropertiesState();
}

class _EditPropertiesState extends State<EditProperties> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Editar propriedade"),
    );
  }
}
