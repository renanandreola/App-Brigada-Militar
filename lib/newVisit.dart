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
import 'package:dropdown_plus/dropdown_plus.dart';

class NewVisit extends StatefulWidget {
  late String userName;
  NewVisit(this.userName);

  @override
  State<NewVisit> createState() => _NewVisitState();
}

class _NewVisitState extends State<NewVisit> {
  final _formKey = GlobalKey<FormState>();

  bool _hasBoard = false;
  int _numberInput = 0;
  List<String> _propertyCodes = [];
  List<String> _propertyCodes2 = [];
  _insertCodes() async {
    final db = await DB.instance.database;

    List<Map> property_codes = await db.query('properties',
        where: "code != 'null'",
        // columns: ["code"],
        orderBy: "code ASC");
    // inspect(property_codes);

    print("${property_codes}");

    for (var property_code in property_codes) {
      List<Map> ownersNames = await db.query('owners',
          where: "_id = '${property_code['fk_owner_id']}'");
      print("ownersNames ${ownersNames}");

      if (ownersNames.length > 0) {
        _propertyCodes2.add(property_code['code'] +
            ' - ' +
            ownersNames[0]['firstname'] +
            ' ' +
            ownersNames[0]['lastname']);
      }
    }

    setState(() {
      // for (var property_code in property_codes) {
      // print(jsonEncode(property_code));
      _propertyCodes = _propertyCodes2;
      // }
      // print(_propertyCodes);
    });
  }

  void _goToNextPage() async {
    print(code);
    List<String> codeFormat = code!.split(' - ');
    code = codeFormat[0];
    // if (_formKey.currentState!.validate()) {
    if (_hasBoard && (code == "" || code == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('C??digo de propriedade n??o selecionado!')),
      );
      return;
    }

    if (_hasBoard) {
      final db = await DB.instance.database;

      // Get property
      List<Map> properties = await db.query(
        'properties',
        where: "code = '${code}'",
      );
      Map property = properties[0];
      await SessionManager().set('edit_property', jsonEncode(property));

      // Get owner
      var owner_id = property["fk_owner_id"];
      List<Map> owners = await db.query('owners', where: "_id = '${owner_id}'");
      Map owner = owners[0];
      await SessionManager().set('edit_owner', jsonEncode(owner));

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => EditOwner(widget.userName)));
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OwnerPage.Owner(widget.userName)));
    // }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _insertCodes();
  }

  String? code = "";

  Widget _geoBoard() {
    List<TextDropdownFormField> componentes = [];
    for (int i = 1; i <= _numberInput; i++) {
      componentes.add(
        TextDropdownFormField(
          options: _propertyCodes,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Preencha uma localidade';
            }
            return null;
          },
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              fillColor: Colors.black,
              focusColor: Colors.green,
              hoverColor: Colors.black,
              iconColor: Colors.black,
              suffixIcon: Icon(Icons.arrow_drop_down),
              labelText: "C??digo da Propriedade"),
          dropdownHeight: 420,
          onChanged: (dynamic val) {
            setState(() {
              // print("Marlon ${val}");
              code = val.toString();
            });
          },
        ),
      );
      // componentes.add(DropdownSearch<String>(
      //   popupProps: PopupProps.menu(
      //     showSelectedItems: true,
      //     disabledItemFn: (String s) => s.startsWith('I'),
      //   ),
      //   items: _propertyCodes,
      //   dropdownDecoratorProps: DropDownDecoratorProps(
      //     dropdownSearchDecoration: InputDecoration(
      //       labelText: "C??digo da Propriedade",
      //       hintText: "",
      //     ),
      //   ),
      //   onChanged: (val) {
      //     setState(() {
      //       code = val;
      //     });
      //   },
      //   //selectedItem: "Brazil",
      // ));
    }
    return Column(
      children: componentes,
    );

    // return Form(
    //     key: _formKey,
    //     child: Column(
    //       children: componentes,
    //     ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: new Center(
        //     child: new Text('NOVO RUMO', textAlign: TextAlign.center)),
        title: Text("Nova Visita"),
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
                          "A Propriedade possui c??digo de georreferenciamento"),
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

                // TextDropdownFormField(
                //   options: ["Marlon", "Renan", "saco"],
                //   decoration: InputDecoration(
                //       border: OutlineInputBorder(),
                //       suffixIcon: Icon(Icons.arrow_drop_down),
                //       labelText: "Gender"),
                //   dropdownHeight: 120,
                // ),

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
                      'Pr??ximo',
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
