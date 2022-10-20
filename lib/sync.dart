import 'package:app_brigada_militar/database/sync/sync.dart';
import 'package:flutter/material.dart';

class Sync extends StatefulWidget {
  const Sync({Key? key}) : super(key: key);

  @override
  State<Sync> createState() => _SyncState();
}

class _SyncState extends State<Sync> {
  bool isSpinner = true;
  bool isSync = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Load new registers
    updateSyncAll().then((updated) {
      if (updated) {
        setState(() {
          // isSpinner = false;
          // isSync = false;

          isSpinner = false;
          isSync = true;
        });
        print("Banco atualizou com sucesso!");
      } else {
        setState(() {
          // isSpinner = false;
          // isSync = true;

          isSpinner = false;
          isSync = false;
        });
        print("Houve um erro ao atualizar o banco");
      }
    });
  }

  Widget statusSync() {
    List<Column> filhos = [];

    if (isSpinner) {
      filhos.add(Column(
        children: [
          // Spinner
          Padding(
            padding: EdgeInsets.only(left: 0, right: 0, top: 0),
            child: Image.asset('assets/images/spinner-sync.png'),
          ),

          // Text sync
          Container(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0, top: 0),
                child: Text("Sincronizando, por favor aguarde",
                    style: TextStyle(
                        fontSize: 30,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                        fontFamily: "RobotoFlex",
                        color: Color.fromARGB(255, 0, 0, 0))),
              ),
            ),
          )
        ],
      ));
    }

    if (!isSpinner && isSync) {
      filhos.add(Column(
        children: [
          // Spinner
          Padding(
            padding: EdgeInsets.only(left: 0, right: 0, top: 0),
            child: Image.asset('assets/images/success-sync.png'),
          ),

          // Text sync
          Container(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0, top: 20),
                child: Text("Banco de Dados sincronizado com sucesso!",
                    style: TextStyle(
                        fontSize: 30,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                        fontFamily: "RobotoFlex",
                        color: Color.fromARGB(255, 0, 0, 0))),
              ),
            ),
          )
        ],
      ));
    }

    if (!isSpinner && !isSync) {
      filhos.add(Column(
        children: [
          // Spinner
          Padding(
            padding: EdgeInsets.only(left: 0, right: 0, top: 0),
            child: Image.asset('assets/images/error-sync.png'),
          ),

          // Text sync
          Container(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0, top: 20),
                child: Text("Houve uma falha ao sincronizar o banco de dados.",
                    style: TextStyle(
                        fontSize: 30,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                        fontFamily: "RobotoFlex",
                        color: Color.fromARGB(255, 0, 0, 0))),
              ),
            ),
          ),

          // Text sync
          Container(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0, top: 30),
                child: Text("Por favor, tente mais tarde.",
                    style: TextStyle(
                        fontSize: 30,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                        fontFamily: "RobotoFlex",
                        color: Color.fromARGB(255, 0, 0, 0))),
              ),
            ),
          )
        ],
      ));
    }

    return Column(
      children: filhos,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sincronizar"),
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
                // Color bar
                Image.asset('assets/images/rectangle.png'),

                // Spinner
                Padding(
                  padding: EdgeInsets.only(left: 59, right: 59, top: 100),
                  child: statusSync(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
