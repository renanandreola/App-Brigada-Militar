import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/sync/sync.dart';
import 'package:app_brigada_militar/home.dart';
import 'package:app_brigada_militar/initialPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:loading_gifs/loading_gifs.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class UpdateInitial extends StatefulWidget {
  const UpdateInitial({Key? key}) : super(key: key);

  @override
  State<UpdateInitial> createState() => _UpdateInitialState();
}

class _UpdateInitialState extends State<UpdateInitial> {
  bool isSpinner = true;
  bool isSync = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    syncDatabase();
  }

  syncDatabase() async {
    try {
      // Call database creation
      final db = await DB.instance.database;

      print("Atualizado!");

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => InitialPage()));
    } catch (e) {
      print("Não Atualizado!");

      setState(() {
        isSpinner = false;
        isSync = false;
      });
    }
  }

  Widget statusSync() {
    List<Column> filhos = [];

    if (isSpinner) {
      filhos.add(Column(
        children: [
          // Spinner
          Padding(
              padding: EdgeInsets.only(left: 0, right: 0, top: 0),
              // child: Image.asset('assets/images/spinner.gif'),
              child: Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                  color: Color.fromARGB(137, 20, 49, 25),
                  size: 180,
                ),
              )),

          // Text sync
          Container(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0, top: 0),
                child: Text("Sincronizando, por favor aguarde",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                        fontFamily: "RobotoFlex",
                        color: Color.fromARGB(255, 0, 0, 0))),
              ),
            ),
          ),
        ],
      ));
    }

    if (!isSpinner && isSync) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => InitialPage()));
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
                    textAlign: TextAlign.start,
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
                    textAlign: TextAlign.start,
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
                    child: SizedBox(
                      width: double.infinity,
                      child: statusSync(),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
