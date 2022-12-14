import 'dart:developer';

import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/editMachines.dart';
import 'package:app_brigada_militar/editPlaceDescription.dart';
import 'package:app_brigada_militar/machines.dart';
import 'package:app_brigada_militar/placeDescription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:location/location.dart';

class EditProperty extends StatefulWidget {
  // const NewPropertie({Key? key}) : super(key: key);
  Map formData;
  late String userName;
  EditProperty(this.formData, this.userName);

  @override
  State<EditProperty> createState() => _EditPropertyState();
}

class _EditPropertyState extends State<EditProperty> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    populate();
  }

  populate() async {
    Map property = await SessionManager().get('edit_property');
    final db = await DB.instance.database;

    String property_type_id = property["fk_property_type_id"];
    List<Map> property_types =
        await db.query('property_types', where: "_id = '${property_type_id}'");
    Map property_type = property_types[0];

    List<Map> property_machines = await db.query(
        'property_agricultural_machines',
        where: "fk_property_id = '${property["_id"]}'");

    setState(() {
      _lat = property["latitude"];
      _lng = property["longitude"];
      _quantityResidents.text = property["qty_people"].toString();
      _area.text = property["area"].toString();
      _hasGeoBoard =  (property["has_geo_board"] == 'true' || property["has_geo_board"] == 1)
          ? true
          : false;
      _hasCams = (property["has_cams"] == 'true' || property["has_cams"] == 1)
          ? true
          : false;
      _hasPhoneSignal = (property["has_phone_signal"] == 'true' ||
              property["has_phone_signal"] == 1)
          ? true
          : false;
      _hasNetwork =
          (property["has_internet"] == 'true' || property["has_internet"] == 1)
              ? true
              : false;
      _dropDownValue = property_type["name"];
      _hasMachines = property_machines.length == 0 ? false : true;
    });
  }

  LocationData? _currentLocalData = null;

  TextEditingController _quantityResidents = TextEditingController();
  TextEditingController _area = TextEditingController();

  String _dropDownValue = '';
  bool _hasCams = false;
  bool _hasPhoneSignal = false;
  bool _hasNetwork = false;
  bool _hasMachines = false;
  bool _hasGeoBoard = false;

  String _lat = "";
  String _lng = "";

  void _goToMachinesOrPlaceDescription() {
    if (_formKey.currentState!.validate()) {
      if (_dropDownValue == "" || _dropDownValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de propriedade n??o selecionado!')),
        );
        return;
      }

      Map formData = widget.formData;

      // Set new form data
      Map pageFormData = {
        'qty_people': _quantityResidents.text,
        'area': _area.text,
        'has_geo_board': _hasGeoBoard,
        'has_cams': _hasCams,
        'has_phone_signal': _hasPhoneSignal,
        'has_internet': _hasNetwork,
        'property_type': _dropDownValue,
        'latitude': _currentLocalData != null
            ? _currentLocalData!.latitude.toString()
            : _lat,
        'longitude': _currentLocalData != null
            ? _currentLocalData!.longitude.toString()
            : _lng,
      };

      // Merge form
      formData.addAll(pageFormData);

      inspect(formData);

      if (_hasMachines) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditMachines(formData, widget.userName)));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditPlaceDescription(formData, widget.userName)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: new Center(
        //     child: new Text('NOVO RUMO', textAlign: TextAlign.center)),
        title: Text("Alterar Propriedade"),
        backgroundColor: Color.fromARGB(255, 27, 75, 27),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                // Color bar
                Image.asset('assets/images/rectangle.png'),

                // Title
                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                    child: Row(
                      children: [
                        Text("Alterar Propriedade",
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),

                Form(
                    key: _formKey,
                    child: Column(children: [
                      Padding(
                        padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Preencha o tamanho da propriedade';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            labelText: "Tamanho da Propriedade (hectares)",
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 1),
                                fontSize: 15,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w400,
                                fontFamily: "RobotoFlex"),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 177, 177, 177)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 177, 177, 177)),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: _area,
                        ),
                      ),
                      // Quantity of peoples
                      Padding(
                        padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Preencha o n??mero de residentes';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            labelText: "Quantidade de residentes",
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 1),
                                fontSize: 15,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w400,
                                fontFamily: "RobotoFlex"),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 177, 177, 177)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 177, 177, 177)),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: _quantityResidents,
                        ),
                      ),
                    ])),

                // Type of Home
                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          // filled: true,
                          fillColor: Colors.black,
                          labelText: 'Tipo de Propriedade'),
                      hint: _dropDownValue == null || _dropDownValue == ""
                          ? Text('',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 1),
                                  fontSize: 15,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "RobotoFlex"))
                          : Text(
                              _dropDownValue,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 1),
                                  fontSize: 15,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "RobotoFlex"),
                            ),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 1),
                          fontSize: 15,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400,
                          fontFamily: "RobotoFlex"),
                      items: ['Casa de Campo', 'Ch??cara', 'S??tio', 'Resid??ncia']
                          .map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(
                          () {
                            _dropDownValue = val.toString();
                          },
                        );
                      },
                    )),

                // Has cams
                Padding(
                    padding: EdgeInsets.only(left: 15, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text(
                          "A propriedade possui placa de georreferenciamento"),
                      activeColor: Color.fromARGB(255, 27, 75, 27),
                      value: _hasGeoBoard,
                      onChanged: (newValue) {
                        setState(() {
                          _hasGeoBoard = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),

                // Has cams
                Padding(
                    padding: EdgeInsets.only(left: 15, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text("H?? c??meras na resid??ncia"),
                      activeColor: Color.fromARGB(255, 27, 75, 27),
                      value: _hasCams,
                      onChanged: (newValue) {
                        setState(() {
                          _hasCams = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),

                // Has phone signal
                Padding(
                    padding: EdgeInsets.only(left: 15, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text("Funciona sinal telef??nico"),
                      activeColor: Color.fromARGB(255, 27, 75, 27),
                      value: _hasPhoneSignal,
                      onChanged: (newValue) {
                        setState(() {
                          _hasPhoneSignal = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),

                // Has network access
                Padding(
                    padding: EdgeInsets.only(left: 15, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text("Possui acesso a internet"),
                      activeColor: Color.fromARGB(255, 27, 75, 27),
                      value: _hasNetwork,
                      onChanged: (newValue) {
                        setState(() {
                          _hasNetwork = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),

                // Has machines
                Padding(
                    padding: EdgeInsets.only(left: 15, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text("H?? m??quina(s) agr??cola(s)"),
                      activeColor: Color.fromARGB(255, 27, 75, 27),
                      value: _hasMachines,
                      onChanged: (newValue) {
                        setState(() {
                          _hasMachines = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),

                // Login
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
                    onPressed: _goToMachinesOrPlaceDescription,
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
