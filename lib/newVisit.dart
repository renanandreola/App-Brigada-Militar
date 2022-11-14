import 'dart:convert';
import 'dart:developer';
import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/models/Owner.dart';
import 'package:app_brigada_militar/editOwner.dart';
import 'package:app_brigada_militar/owner.dart' as OwnerPage;
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:sqflite/sqflite.dart';

class NewVisit extends StatefulWidget {
  const NewVisit({Key? key}) : super(key: key);

  @override
  State<NewVisit> createState() => _NewVisitState();
}

class _NewVisitState extends State<NewVisit> {
  bool _hasBoard = false;
  int _numberInput = 0;
  List<String> _propertyCodes = [];
  _insertCodes() async {
    final db = await DB.instance.database;

    List<Map> property_codes = await db.query('properties',
        where: "code LIKE '%ERE%'",
        // columns: ["code"],
        orderBy: "code ASC");
    // inspect(property_codes);

    setState(() {
      for (var property_code in property_codes) {
        print(jsonEncode(property_code));
        _propertyCodes.add(property_code['code']);
      }
      print(_propertyCodes);
    });
  }

  void _goToNextPage() async {
    if (_hasBoard) {
      final db = await DB.instance.database;

      // Get property
      List<Map> properties = await db.query('properties',
        where: "code = '${code}'",
      );
      Map property = properties[0];
      await SessionManager().set('edit_property', jsonEncode(property));

      // Get owner
      var owner_id = property["fk_owner_id"];
      List<Map> owners = await db.query('owners',
        where: "_id = '${owner_id}'"
      );
      Map owner = owners[0];
      await SessionManager().set('edit_owner', jsonEncode(owner));

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => EditOwner()));
      return;
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => OwnerPage.Owner()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _insertCodes();
  }

  String? code = "";

  Widget _geoBoard() {
    List<DropdownSearch> componentes = [];
    for (int i = 1; i <= _numberInput; i++) {
      componentes.add(DropdownSearch<String>(
        popupProps: PopupProps.menu(
          showSelectedItems: true,
          disabledItemFn: (String s) => s.startsWith('I'),
        ),
        items: _propertyCodes,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Código da Propriedade",
            hintText: "",
          ),
        ),
        onChanged: (val) {
          setState(() {
            code = val;
          });
        },
        //selectedItem: "Brazil",
      ));
    }
    return Column(
      children: componentes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: new Center(
        //     child: new Text('NOVO RUMO', textAlign: TextAlign.center)),
        title: new Center(
            child: new Text(
          "Nova Visita",
          textAlign: TextAlign.center,
        )),
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
                        Text("Nova Visita",
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(left: 15, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text(
                          "A Propriedade possui placa de georreferenciamento"),
                      activeColor: Color.fromARGB(255, 27, 75, 27),
                      value: _hasBoard,
                      onChanged: (newValue) {
                        setState(() {
                          _hasBoard = newValue!;
                          _hasBoard ? _numberInput = 1 : _numberInput = 0;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),
                // Title

                // ResponsibleName
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                  child: _geoBoard(),
                ),

                // Next
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 35),
                  child: ElevatedButton(
                    child: Text(
                      'Próximo',
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
                    onPressed: _goToNextPage,
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