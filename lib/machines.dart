import 'package:flutter/material.dart';

class Machines extends StatefulWidget {
  const Machines({Key? key}) : super(key: key);

  @override
  State<Machines> createState() => _MachinesState();
}

class _MachinesState extends State<Machines> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Máquinas"),
      ),
    );
  }
}
