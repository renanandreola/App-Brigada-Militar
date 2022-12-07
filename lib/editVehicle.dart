import 'dart:convert';
import 'dart:developer';
import 'package:app_brigada_militar/editAditionalInfo.dart';
import 'package:app_brigada_militar/editVehicle.dart';
import 'package:app_brigada_militar/aditionalInfo.dart';
import 'package:app_brigada_militar/database/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:dropdown_plus/dropdown_plus.dart';

class EditVehicle extends StatefulWidget {
  // const Vehicle({Key? key}) : super(key: key);
  Map formData;
  late String userName;
  EditVehicle(this.formData, this.userName);

  @override
  State<EditVehicle> createState() => _EditVehicleState();
}

List<String> _carList = [];
List<Map<String?, String?>> vehiclesInfo = [];

class _EditVehicleState extends State<EditVehicle> {
  List<TextEditingController> _vehicleIdentification = [];
  List<TextEditingController> _vehicleColor = [];
  List<TextEditingController> _newVehicleName = [];
  List<TextEditingController> _newVehicleBrand =  [];
  final _formKey = GlobalKey<FormState>();

  // bool _hasOtherVehicle = false;
  int _numberInput = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCarList();
  }

  _getCarList() async {
    final db = await DB.instance.database;
    List<Map> vehicles = await db.query('vehicles');

    List<String> list = [];
    for (var vehicle in vehicles) {
      list.add(vehicle["name"] + " - " + vehicle["brand"]);
      vehiclesInfo.add({
        "name": vehicle["name"] + " - " + vehicle["brand"],
        "key": vehicle["_id"]
      });
    }

    list.add("Outro");

    vehiclesInfo.add({
      "name": "Outro",
      "key": "0",
    });

    setState(() {
      _carList = list;

      _carList.map(
        (val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Text(val),
          );
        },
      ).toList();
    });

    populateScreen();
  }

  populateScreen() async {
    Map property = await SessionManager().get('edit_property');

    final db = await DB.instance.database;
    var property_id = property["_id"];

    print(property_id);

    List<Map> vehicles_filtered = await db.query('property_vehicles',
        where: "fk_property_id = '${property_id}'");
    var vehicles = [];

    // var a = vehicles_filtered[0]['fk_vehicle_id'];

    for (var i = 0; i < vehicles_filtered.length; i++) {
      List<Map> vehicle_list = await db.query('vehicles',
          where: "_id = '${vehicles_filtered[i]['fk_vehicle_id']}'");
      vehicles.add(vehicle_list[0]);

      _vehicleIdentification[i].text = vehicles_filtered[i]["identification"];
      _vehicleColor[i].text = vehicles_filtered[i]["color"];
    }

    print(vehicles);

    var j = 0;
    for (var vehicleFinal in vehicles) {
      _vehicleType.add({"name": "", "key": ""});
      _vehicleIdentification.add(TextEditingController());
      _vehicleColor.add(TextEditingController());

      setState(() {
        _vehicleType[j]["name"] =
            vehicleFinal["name"] + ' - ' + vehicleFinal["brand"];
        _vehicleType[j]["key"] = vehicleFinal["_id"];
      });

      inspect(_vehicleIdentification);
      inspect(_vehicleColor);

      j++;
    }

    setState(() {
      _vehicleType.removeLast();
      numberVehicles = vehicles.length;
    });

    if (_vehicleType.length > 0 && _vehicleType.last["name"] == "") {
      setState(() {
        _vehicleType.removeLast();
      });
    }

    if (vehicles.length > 0) {
      numberVehicles--;
    }
  }

  String _vehicleType1 = '';
  List _vehicleType = [];
  int numberVehicles = 1;

  // Add new vehicle
  void addNewVehicle() {
    setState(() {
      numberVehicles += 1;
    });
  }

  // Remove all machines
  void removeVehicles() {
    if (numberVehicles >= 0) {
      setState(() {
        _vehicleType.removeLast();
        _vehicleIdentification.removeLast();
        _vehicleColor.removeLast();
        _newVehicleName.removeLast();
        _newVehicleBrand.removeLast();
        numberVehicles -= 1;
      });
    }
  }

  void _goToAditionalInfo() async {
    for (var i = 0; i < _vehicleType.length; i++) {
      _vehicleType[i]["identification"] = _vehicleIdentification[i].text;
      _vehicleType[i]["color"] = _vehicleColor[i].text;
      
      if (_vehicleType[i]["key"] == "0") {
        _vehicleType[i]["name"] = _newVehicleName[i].text;
        _vehicleType[i]["brand"] = _newVehicleBrand[i].text;
      }
    }

    if (numberVehicles < 0 || _vehicleType[0]['name'] == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum veículo selecionado!')),
      );
      return;
    }
    await SessionManager().set('edit_vehicles', jsonEncode(_vehicleType));

    inspect(await SessionManager().get('edit_vehicles'));

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditAditionalInfo(widget.formData, widget.userName)));
  }

  Widget vehicleType1() {
    List<Row> filhos = [];
    for (int i = 0; i <= numberVehicles; i++) {
      if (_vehicleType.length - 1 < i) {
        _vehicleType
            .add({"name": "", "key": "", "identification": "", "color": ""});

        _vehicleIdentification.add(TextEditingController());
        _vehicleColor.add(TextEditingController());
        _newVehicleName.add(TextEditingController());
        _newVehicleBrand.add(TextEditingController());
      }

      // Vehicle name 
      filhos.add(
        Row(
          children: [
            Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: TextDropdownFormField(
                      options: _carList,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Preencha uma Veículo';
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
                          labelText: _vehicleType[i]["name"] == null ||
                                  _vehicleType[i]["name"] == ''
                              ? 'Veículo ${i}'
                              : _vehicleType[i]["name"]),
                      dropdownHeight: 420,
                      onChanged: (dynamic val) {
                        setState(
                          () {
                            Map currentVehicle = vehiclesInfo
                                .where((element) =>
                                    element["name"] == val.toString())
                                .first;
                            _vehicleType[i]["name"] = val.toString();
                            _vehicleType[i]["key"] = currentVehicle["key"];
                          },
                        );
                      },
                    )))
          ],
        ),
      );

      if (_vehicleType[i]["name"] == "Outro") {
        //New Vehicle Name
        filhos.add(Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Padding(
                padding: EdgeInsets.only(top: 5),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preencha o nome do Veículo';
                    }
                    return null;
                  },
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: "Nome do Veículo",
                    labelStyle: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 1),
                        fontSize: 15,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                        fontFamily: "RobotoFlex"),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 177, 177, 177)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 177, 177, 177)),
                    ),
                  ),
                  keyboardType: TextInputType.name,
                  controller: _newVehicleName[i],
                ),
              ),
            )
          ],
        ));

        //New Vehicle Name
        filhos.add(Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Padding(
                padding: EdgeInsets.only(top: 5),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preencha a marca do Veículo';
                    }
                    return null;
                  },
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: "Marca do Veículo",
                    labelStyle: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 1),
                        fontSize: 15,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                        fontFamily: "RobotoFlex"),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 177, 177, 177)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 177, 177, 177)),
                    ),
                  ),
                  keyboardType: TextInputType.name,
                  controller:  _newVehicleBrand[i],
                ),
              ),
            )
          ],
        ));
      }

      // Vehicle identification
      filhos.add(Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Padding(
              padding: EdgeInsets.only(top: 5),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Preencha a placa do veículo';
                  }
                  return null;
                },
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: "Placa do Veículo",
                  labelStyle: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 1),
                      fontSize: 15,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                      fontFamily: "RobotoFlex"),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 177, 177, 177)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 177, 177, 177)),
                  ),
                ),
                keyboardType: TextInputType.name,
                controller: _vehicleIdentification[i],
              ),
            ),
          )
        ],
      ));

      //Vehicle Color  
      filhos.add(Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Padding(
              padding: EdgeInsets.only(top: 5),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Preencha a cor do veículo';
                  }
                  return null;
                },
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: "Cor do Veículo",
                  labelStyle: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 1),
                      fontSize: 15,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                      fontFamily: "RobotoFlex"),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 177, 177, 177)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 177, 177, 177)),
                  ),
                ),
                keyboardType: TextInputType.name,
                controller: _vehicleColor[i],
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
        // title: new Center(
        //     child: new Text('NOVO RUMO', textAlign: TextAlign.center)),
        title: Text("Nova propriedade"),
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
                        Text("Veículos",
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),

                // Type of vehicle
                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 20),
                    child: vehicleType1()),

                // Padding(
                //     padding: EdgeInsets.only(left: 15, right: 32, top: 5),
                //     child: CheckboxListTile(
                //       title: Text("Outro(a)"),
                //       activeColor: Color.fromARGB(255, 27, 75, 27),
                //       value: _hasOtherVehicle,
                //       onChanged: (newValue) {
                //         setState(() {
                //           _hasOtherVehicle = newValue!;
                //           _hasOtherVehicle
                //               ? _numberInput = 1
                //               : _numberInput = 0;
                //         });
                //       },
                //       controlAffinity: ListTileControlAffinity
                //           .leading, //  <-- leading Checkbox
                //     )),

                // Padding(
                //   padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                //   child: _otherVehicle(),
                // ),

                // Add new vehicle
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 30),
                  child: GestureDetector(
                    onTap: () {
                      addNewVehicle();
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        '+ Veículo',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: Color.fromARGB(255, 27, 75, 27),
                            fontSize: 18,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600,
                            fontFamily: "RobotoFlex"),
                      ),
                    ),
                  ),
                ),

                // Remove vehicles
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 30),
                  child: GestureDetector(
                    onTap: () {
                      removeVehicles();
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        '- Remover Veículos',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: Color.fromARGB(255, 27, 75, 27),
                            fontSize: 18,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600,
                            fontFamily: "RobotoFlex"),
                      ),
                    ),
                  ),
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
                    onPressed: _goToAditionalInfo,
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
