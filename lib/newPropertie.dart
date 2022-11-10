import 'dart:developer';

import 'package:app_brigada_militar/machines.dart';
import 'package:app_brigada_militar/placeDescription.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class NewPropertie extends StatefulWidget {
  // const NewPropertie({Key? key}) : super(key: key);
  Map formData;
  NewPropertie(this.formData);

  @override
  State<NewPropertie> createState() => _NewPropertieState();
}

class _NewPropertieState extends State<NewPropertie> {
  LocationData? _currentLocalData = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getPosition();
  }

  _getPosition() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    inspect(_locationData);
    _currentLocalData = _locationData;
  }

  TextEditingController _quantityResidents = TextEditingController();

  String _dropDownValue = '';
  bool _hasSign = false;
  bool _hasCams = false;
  bool _hasPhoneSignal = false;
  bool _hasNetwork = false;
  bool _hasMachines = false;

  void _goToMachinesOrPlaceDescription() {

    Map formData = widget.formData;
  
    // Set new form data
    Map pageFormData = {
      'qty_people': _quantityResidents.text,
      'has_geo_board': _hasSign,
      'has_cams': _hasCams,
      'has_phone_signal': _hasPhoneSignal,
      'has_internet': _hasNetwork,
      'property_type': _dropDownValue,
      'latitude': _currentLocalData!.latitude.toString(),
      'longitude': _currentLocalData!.longitude.toString()
    };

    // Merge form
    formData.addAll(pageFormData);

    if (_hasMachines) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Machines(formData)));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PlaceDescription(formData)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: new Center(
        //     child: new Text('NOVO RUMO', textAlign: TextAlign.center)),
        title: Text("Nova propriedade"),
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

                // Title
                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                    child: Row(
                      children: [
                        Text("Nova Propriedade",
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),

                // Quantity of peoples
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Preencha o número de residentes';
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

                // Type of Home
                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                    child: DropdownButton(
                      hint: _dropDownValue == null || _dropDownValue == ""
                          ? Text('Tipo de propriedade',
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
                      items: ['Casa de Campo', 'Chácara', 'Sítio', 'Residência']
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

                // Sign Home
                Padding(
                    padding: EdgeInsets.only(left: 15, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text("Possui placa de georreferenciamento"),
                      activeColor: Color.fromARGB(255, 27, 75, 27),
                      value: _hasSign,
                      onChanged: (newValue) {
                        setState(() {
                          _hasSign = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),

                // Has cams
                Padding(
                    padding: EdgeInsets.only(left: 15, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text("Há câmeras na residência"),
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
                      title: Text("Funciona sinal telefônico"),
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
                      title: Text("Há máquina(s) agrícola(s)"),
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
