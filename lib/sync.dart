import 'package:app_brigada_militar/database/sync/sync.dart';
import 'package:flutter/material.dart';

class Sync extends StatefulWidget {
  const Sync({Key? key}) : super(key: key);

  @override
  State<Sync> createState() => _SyncState();
}

class _SyncState extends State<Sync> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Load new registers
    updateSyncAll().then((updated) {
      if (updated) {
        print("Banco atualizou com sucesso!");
      } else {
        print("Houve um erro ao atualizar o banco");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Sincronizar"),
    );
  }
}
