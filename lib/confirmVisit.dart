import 'package:app_brigada_militar/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class ConfirmVisit extends StatefulWidget {
  const ConfirmVisit({Key? key}) : super(key: key);

  @override
  State<ConfirmVisit> createState() => _ConfirmVisitState();
}

class _ConfirmVisitState extends State<ConfirmVisit> {
  String _policesNames = "";
  String _vtrCode = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getGarrisonInfo();
  }

  _getGarrisonInfo() async {
    var garrison = await SessionManager().get("garrison");
    var vtr = await SessionManager().get("vtr");

    setState(() {
      _vtrCode = vtr;

      for (var item in garrison) {
        var nameItem = item["name"];
        _policesNames += "• ${nameItem}\n";
      }
    });
    print(_policesNames);
  }

  _confirmVisit() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeApp("nome")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: new Center(
        //     child: new Text('NOVO RUMO', textAlign: TextAlign.center)),
        title: Text(
          "Confirmar Visita",
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
                // Color bar
                Image.asset('assets/images/rectangle.png'),
                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                    child: Row(
                      children: [
                        Text("Confirmar Visita",
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),

                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 20),
                    child: Row(
                      children: [
                        Text("Guarnição",
                            style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),

                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 10),
                    child: Row(
                      children: [
                        Text(_policesNames,
                            style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),

                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 10),
                    child: Row(
                      children: [
                        Text("Viatura: ${_vtrCode}",
                            style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),

                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 20),
                    child: Row(
                      children: [
                        Text("Alterar Guarnição",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 27, 75, 27),
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),

                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 35),
                  child: ElevatedButton(
                    child: Text(
                      'Confirmar Visita',
                      style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w600,
                          fontFamily: "RobotoFlex"),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 27, 75, 27),
                      elevation: 2,
                      fixedSize: Size(330, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _confirmVisit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
