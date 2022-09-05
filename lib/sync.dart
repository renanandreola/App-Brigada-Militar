import 'package:flutter/material.dart';

class Sync extends StatefulWidget {
  const Sync({Key? key}) : super(key: key);

  @override
  State<Sync> createState() => _SyncState();
}

class _SyncState extends State<Sync> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Sincronizar"),
    );
  }
}
