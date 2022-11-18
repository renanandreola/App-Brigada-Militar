import 'dart:convert';
import 'dart:developer';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:app_brigada_militar/aditionalInfo.dart';
import 'package:app_brigada_militar/database/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class Vehicle extends StatefulWidget {
  // const Vehicle({Key? key}) : super(key: key);
  Map formData;
  Vehicle(this.formData);

  @override
  State<Vehicle> createState() => _VehicleState();
}

List<String> _carList = [];
List<Map<String?, String?>> vehiclesInfo = [];

class _VehicleState extends State<Vehicle> {
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
  }

  String _vehicleType1 = '';
  List _vehicleType = [];
  int numberVehicles = 0;

  // Add new vehicle
  void addNewVehicle() {
    setState(() {
      numberVehicles += 1;
    });
  }

  // Remove all machines
  void removeVehicles() {
    setState(() {
      _vehicleType.removeLast();
      numberVehicles -= 1;
    });
  }

  void _goToAditionalInfo() async {
    if (_vehicleType[0]['name'] == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum veículo selecionado!')),
      );
      return;
    }
    await SessionManager().set('vehicles', jsonEncode(_vehicleType));

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AditionalInfo(widget.formData)));
  }

  Widget vehicleType1() {
    List<Row> filhos = [];
    for (int i = 0; i <= numberVehicles; i++) {
      if (_vehicleType.length - 1 < i) {
        _vehicleType.add({"name": "", "key": ""});
      }
      filhos.add(Row(
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
                        labelText: "Veículo ${i}"),
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
      )
          //   DropdownButtonFormField(
          //   hint: _vehicleType[i]["name"] == null || _vehicleType[i]["name"] == ""
          //       ? Text('Veículo ${i}',
          //           style: TextStyle(
          //               color: Color.fromARGB(255, 0, 0, 1),
          //               fontSize: 15,
          //               fontStyle: FontStyle.normal,
          //               fontWeight: FontWeight.w400,
          //               fontFamily: "RobotoFlex"))
          //       : Text(
          //           _vehicleType[i]["name"],
          //           style: TextStyle(
          //               color: Color.fromARGB(255, 0, 0, 1),
          //               fontSize: 15,
          //               fontStyle: FontStyle.normal,
          //               fontWeight: FontWeight.w400,
          //               fontFamily: "RobotoFlex"),
          //         ),
          //   decoration: InputDecoration(
          //       // filled: true,
          //       fillColor: Colors.black,
          //       labelText: 'Veículo ${i}'),
          //   isExpanded: true,
          //   iconSize: 30.0,
          //   style: TextStyle(
          //       color: Color.fromARGB(255, 0, 0, 1),
          //       fontSize: 15,
          //       fontStyle: FontStyle.normal,
          //       fontWeight: FontWeight.w400,
          //       fontFamily: "RobotoFlex"),
          //   items: _carList.map(
          //     (val) {
          //       return DropdownMenuItem<String>(
          //         value: val,
          //         child: Text(val),
          //       );
          //     },
          //   ).toList(),
          //   onChanged: (val) {
          //     setState(
          //       () {
          //         Map currentVehicle = vehiclesInfo
          //             .where((element) => element["name"] == val.toString())
          //             .first;
          //         _vehicleType[i]["name"] = val.toString();
          //         _vehicleType[i]["key"] = currentVehicle["key"];
          //       },
          //     );
          //   },
          // )
          );
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
