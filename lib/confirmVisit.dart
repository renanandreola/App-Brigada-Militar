import 'dart:developer';
import 'package:app_brigada_militar/editGarrison.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/utils/datetimeToStr.dart';
import 'package:app_brigada_militar/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class ConfirmVisit extends StatefulWidget {
  // const ConfirmVisit({Key? key}) : super(key: key);
  String? property_id;
  late String userName;
  String? history;
  ConfirmVisit(this.property_id, this.userName, this.history);

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
        _policesNames += "- ${nameItem}\n";
      }
    });
    print(_policesNames);
  }

  _confirmVisit() async {
    var garrison = await SessionManager().get("garrison");
    var vtr = await SessionManager().get("vtr");

    //Create a transaction to avoid atomicity errors
    final db = await DB.instance.database;

    await db.transaction((txn) async {
      final DateTime now = DateTime.now();
      String datetimeStr = datetimeToStr(now);

      await txn.insert('visits', {
        "car": vtr,
        "fk_property_id": widget.property_id,
        "date": datetimeStr,
        "history": widget.history,
        "createdAt": datetimeStr,
        "updatedAt": datetimeStr
      });

      String table = 'visits';
      List<Map> list = await txn.query(table,
          where: "fk_property_id = '${widget.property_id}' AND car = '${vtr}'",
          orderBy: "createdAt DESC",
          limit: 1);
      Map elem = list[0];
      await txn.insert('database_updates',
          {'reference_table': table, 'updated_id': elem["_id"]});

      List<Map> visits =
          await txn.query('visits', orderBy: "createdAt DESC", limit: 1);
      Map visit = visits[0];

      for (var user in garrison) {
        txn.insert('user_visits', {
          "fk_visit_id": visit["_id"],
          "fk_user_id": user["key"],
          "createdAt": datetimeStr,
          "updatedAt": datetimeStr
        });

        String table = 'user_visits';
        List<Map> list = await txn.query(table,
            where:
                "fk_visit_id = '${visit["_id"]}' AND fk_user_id = '${user["key"]}'",
            orderBy: "createdAt DESC",
            limit: 1);
        Map elem = list[0];
        await txn.insert('database_updates',
            {'reference_table': table, 'updated_id': elem["_id"]});
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visita cadastrada com sucesso!')),
    );

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => HomeApp(widget.userName)));
  }

  void _changeGarrison() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditGarrison(widget.userName, 'from_page_confirm')));
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
                        Text.rich(
                          TextSpan(
                            children: [
                              WidgetSpan(child: Icon(Icons.group)),
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 10, right: 32),
                            child: Row(
                              children: [
                                Text("Guarnição:",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "RobotoFlex")),
                              ],
                            )),
                      ],
                    )),

                // Padding(
                //     padding: EdgeInsets.only(left: 32, right: 32, top: 10),
                //     child: Row(
                //       children: [
                //         Text(_policesNames,
                //             style: TextStyle(
                //                 fontSize: 15,
                //                 fontStyle: FontStyle.normal,
                //                 fontWeight: FontWeight.bold,
                //                 fontFamily: "RobotoFlex")),
                //       ],
                //     )),

                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 10),
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(50.0),
                        child: Column(
                          children: [
                            Text(_policesNames,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontFamily: "RobotoFlex"))
                          ],
                        ),
                      ),
                    )),

                // Padding(
                //     padding: EdgeInsets.only(left: 32, right: 32, top: 10),
                //     child: Row(
                //       children: [
                //         Text("Viatura: ${_vtrCode}",
                //             style: TextStyle(
                //                 fontSize: 15,
                //                 fontStyle: FontStyle.normal,
                //                 fontWeight: FontWeight.bold,
                //                 fontFamily: "RobotoFlex")),
                //       ],
                //     )),

                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 20),
                    child: Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              WidgetSpan(
                                  child: Icon(Icons.directions_car_rounded)),
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 10, right: 32),
                            child: Row(
                              children: [
                                Text("Viatura utilizada:",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "RobotoFlex")),
                              ],
                            )),
                      ],
                    )),

                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 10),
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(50.0),
                        child: Column(
                          children: [
                            Text(_vtrCode,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontFamily: "RobotoFlex"))
                          ],
                        ),
                      ),
                    )),

                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 25),
                  child: GestureDetector(
                    child: SizedBox(
                      width: double.infinity,
                      child: Text("Alterar Guarnição",
                          style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 27, 75, 27),
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                              fontFamily: "RobotoFlex")),
                    ),
                    onTap: _changeGarrison,
                  ),
                ),

                // Padding(
                //     padding: EdgeInsets.only(left: 32, right: 32, top: 20),
                //     child: Row(
                //       children: [
                //         Text("Alterar Guarnição",
                //             style: TextStyle(
                //                 fontSize: 15,
                //                 color: Color.fromARGB(255, 27, 75, 27),
                //                 fontStyle: FontStyle.normal,
                //                 fontWeight: FontWeight.bold,
                //                 fontFamily: "RobotoFlex")),
                //       ],
                //     )),

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
