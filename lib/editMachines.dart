import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/editPlaceDescription.dart';
import 'package:app_brigada_militar/placeDescription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class EditMachines extends StatefulWidget {
  // const Machines({Key? key}) : super(key: key);
  Map formData;
  EditMachines(this.formData);

  @override
  State<EditMachines> createState() => _EditMachinesState();
}

List _machineList = [];
List<Map<String?, String?>> machinesInfo = [];

class _EditMachinesState extends State<EditMachines> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMachineList();
  }

  _getMachineList() async {
    final db = await DB.instance.database;
    List<Map> machines = await db.query('agricultural_machines');

    List list = [];
    for (var machine in machines) {
      list.add(machine["name"]);
      machinesInfo.add({"name": machine["name"], "key": machine["_id"]});
    }

    setState(() {
      _machineList = list;
    });

    populateScreen();
  }

  populateScreen() async {
    Map property = await SessionManager().get('edit_property');

    final db = await DB.instance.database;
    var property_id = property["_id"];

    print(property_id);

    List<Map> machinesFiltered = await db.query(
        'property_agricultural_machines',
        where: "fk_property_id = '${property_id}'");
    var agricultural_machines = [];

    // var a = machinesFiltered[0]['fk_vehicle_id'];

    for (var i = 0; i < machinesFiltered.length; i++) {
      List<Map> agricultural_machine_list = await db.query(
          'agricultural_machines',
          where:
              "_id = '${machinesFiltered[i]['fk_agricultural_machine_id']}'");
      agricultural_machines.add(agricultural_machine_list[0]);
    }

    var j = 0;
    for (var machineFinal in agricultural_machines) {
      _machineType.add({"name": "", "key": ""});

      setState(() {
        _machineType[j]["name"] = machineFinal["name"];
        _machineType[j]["key"] = machineFinal["_id"];
      });

      j++;
    }

    setState(() {
      _machineType.removeLast();
      numberMachines = agricultural_machines.length;
    });

    if (_machineType.length > 0 && _machineType.last["name"] == "") {
      setState(() {
        _machineType.removeLast();
      });
    }

    if (agricultural_machines.length > 0) {
      numberMachines--;
    }

    // print(agricultural_machines);
  }

  List _machineType = [];
  int numberMachines = 1;

  // Increments the number of machines on click '+ Máquinas Agrícolas'
  void addNewMachine() {
    setState(() {
      numberMachines += 1;
    });
  }

  // Remove all machines
  void removeMachines() {
    if (numberMachines >= 0) {
      setState(() {
        _machineType.removeLast();
        numberMachines -= 1;
      });
    }
  }

  // Go to page that have the description of the place
  void _goToPlaceDescription() async {
    if (numberMachines < 0 || _machineType[0]['name'] == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma máquina selecionada!')),
      );
      return;
    }

    await SessionManager().set('edit_agricultural_machines', jsonEncode(_machineType));

    inspect(await SessionManager().get('edit_agricultural_machines'));

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditPlaceDescription(widget.formData)));
  }

  // Show the dropdown on click '+ Máquinas Agrícolas'
  Widget machineType1() {
    List<Row> filhos = [];
    for (int i = 0; i <= numberMachines; i++) {
      if (_machineType.length - 1 < i) {
        _machineType.add({"name": "", "key": ""});
      }
      filhos.add(Row(
        children: [
          Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: DropdownButtonFormField(
                hint: _machineType[i]["name"] == null ||
                        _machineType[i]["name"] == ""
                    ? Text('Máquina Agrícola ${i}',
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 1),
                            fontSize: 15,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            fontFamily: "RobotoFlex"))
                    : Text(
                        _machineType[i]["name"],
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
                    labelText: 'Máquina Agrícola ${i}'),
                isExpanded: true,
                iconSize: 30.0,
                style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 1),
                    fontSize: 15,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                    fontFamily: "RobotoFlex"),
                items: _machineList.map(
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
                      Map currentMachine = machinesInfo
                          .where((element) => element["name"] == val.toString())
                          .first;

                      _machineType[i]["name"] = val.toString();
                      _machineType[i]["key"] = currentMachine["key"];
                    },
                  );
                },
              )),
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
        title: Text("Alterar Propriedade"),
        backgroundColor: Color.fromARGB(255, 27, 75, 27),
        leading: GestureDetector(
          onTap: () {/* Write listener code here */},
          child: Icon(
            Icons.menu,
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
                        Text("Máquinas Agrícolas",
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),

                // Type of machines
                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 20),
                    child: machineType1()),

                // Add new machine
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 30),
                  child: GestureDetector(
                    onTap: () {
                      addNewMachine();
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        '+ Máquina Agrícola',
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

                // Remove machines
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 30),
                  child: GestureDetector(
                    onTap: () {
                      removeMachines();
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        '- Remover Máquinas',
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

                // Next Page
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
                    onPressed: _goToPlaceDescription,
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
