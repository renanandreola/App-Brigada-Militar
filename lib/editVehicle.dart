import 'dart:convert';
import 'dart:developer';
import 'package:app_brigada_militar/editVehicle.dart';
import 'package:app_brigada_militar/aditionalInfo.dart';
import 'package:app_brigada_militar/database/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class EditVehicle extends StatefulWidget {
  // const Vehicle({Key? key}) : super(key: key);
  Map formData;
  EditVehicle(this.formData);

  @override
  State<EditVehicle> createState() => _EditVehicleState();
}

List _carList = [];
List<Map<String?, String?>> vehiclesInfo = [];

class _EditVehicleState extends State<EditVehicle> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCarList();
  }

  _getCarList() async {
    final db = await DB.instance.database;
    List<Map> vehicles = await db.query('vehicles');

    List list = [];
    for (var vehicle in vehicles) {
      list.add(vehicle["name"] + " - " + vehicle["brand"]);
      vehiclesInfo.add({
        "name": vehicle["name"] + " - " + vehicle["brand"],
        "key": vehicle["_id"]
      });
    }

    setState(() {
      _carList = list;
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
      vehicles.add(await db.query('vehicles',
          where: "_id = '${vehicles_filtered[i]['fk_vehicle_id']}'"));
    }

    print(vehicles);

    var j = 0;
    for (var vehicleFinal in vehicles) {
      _vehicleType.add({"name": "", "key": ""});

      setState(() {
        _vehicleType[j]["name"] = vehicleFinal[j]["name"];
        _vehicleType[j]["key"] = vehicleFinal[j]["_id"];
      });

      j++;
    }

    setState(() {
      _vehicleType.removeLast();
      numberVehicles = vehicles.length - 1;
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
    await SessionManager().set('vehicles', jsonEncode(_vehicleType));

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AditionalInfo(widget.formData)));
  }

  Widget vehicleType1() {
    List<DropdownButtonFormField> filhos = [];
    for (int i = 0; i <= numberVehicles; i++) {
      if (_vehicleType.length - 1 < i) {
        _vehicleType.add({"name": "", "key": ""});
      }
      filhos.add(DropdownButtonFormField(
        hint: _vehicleType[i]["name"] == null || _vehicleType[i]["name"] == ""
            ? Text('Veículo ${i}',
                style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 1),
                    fontSize: 15,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                    fontFamily: "RobotoFlex"))
            : Text(
                _vehicleType[i]["name"],
                style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 1),
                    fontSize: 15,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                    fontFamily: "RobotoFlex"),
              ),
        decoration: InputDecoration(
            // filled: true,
            fillColor: Colors.black,
            labelText: 'Veículo ${i}'),
        isExpanded: true,
        iconSize: 30.0,
        style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 1),
            fontSize: 15,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w400,
            fontFamily: "RobotoFlex"),
        items: _carList.map(
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
              Map currentVehicle = vehiclesInfo
                  .where((element) => element["name"] == val.toString())
                  .first;
              _vehicleType[i]["name"] = val.toString();
              _vehicleType[i]["key"] = currentVehicle["key"];
            },
          );
        },
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
