import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/editPlaceDescription.dart';
import 'package:app_brigada_militar/placeDescription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:dropdown_plus/dropdown_plus.dart';

class EditMachines extends StatefulWidget {
  // const Machines({Key? key}) : super(key: key);
  Map formData;
  late String userName;
  EditMachines(this.formData, this.userName);

  @override
  State<EditMachines> createState() => _EditMachinesState();
}

List<String> _machineList = [];
List<Map<String?, String?>> machinesInfo = [];

class _EditMachinesState extends State<EditMachines> {
  TextEditingController _otherValue = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // bool _hasOtherMachine = false;
  int _numberInput = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMachineList();
  }

  _getMachineList() async {
    final db = await DB.instance.database;
    List<Map> machines = await db.query('agricultural_machines');

    List<String> list = [];
    for (var machine in machines) {
      list.add(machine["name"]);
      machinesInfo.add({"name": machine["name"], "key": machine["_id"]});
    }

    setState(() {
      _machineList = list;

      _machineList.map(
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

  // Increments the number of machines on click '+ M??quinas Agr??colas'
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
    // if (_hasOtherMachine && _otherValue.text != "") {
    //   _machineType[0]['name'] = _otherValue.text;
    // }

    // if (_hasOtherMachine && _otherValue.text == "") {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Nenhuma m??quina selecionada!')),
    //   );
    //   return;
    // }

    if (numberMachines < 0 || _machineType[0]['name'] == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma m??quina selecionada!')),
      );
      return;
    }

    await SessionManager()
        .set('edit_agricultural_machines', jsonEncode(_machineType));

    inspect(await SessionManager().get('edit_agricultural_machines'));

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditPlaceDescription(widget.formData, widget.userName)));
  }

  // Widget _otherMachine() {
  //   List<Form> componentes = [];
  //   for (int i = 1; i <= _numberInput; i++) {
  //     componentes.add(Form(
  //         key: _formKey,
  //         child: Column(children: [
  //           Padding(
  //             padding: EdgeInsets.only(left: 0, right: 0, top: 5),
  //             child: TextFormField(
  //               validator: (value) {
  //                 if (value == null || value.isEmpty) {
  //                   return 'Preencha a m??quina';
  //                 }
  //                 return null;
  //               },
  //               cursorColor: Colors.black,
  //               decoration: InputDecoration(
  //                 labelText: "Nome da m??quina",
  //                 labelStyle: TextStyle(
  //                   color: Color.fromARGB(255, 88, 88, 88),
  //                 ),
  //                 enabledBorder: UnderlineInputBorder(
  //                   borderSide:
  //                       BorderSide(color: Color.fromARGB(255, 88, 88, 88)),
  //                 ),
  //                 focusedBorder: UnderlineInputBorder(
  //                   borderSide: BorderSide(color: Colors.black),
  //                 ),
  //               ),
  //               keyboardType: TextInputType.text,
  //               controller: _otherValue,
  //             ),
  //           ),
  //         ])));
  //   }
  //   return Column(
  //     children: componentes,
  //   );
  // }

  // Show the dropdown on click '+ M??quinas Agr??colas'
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
              // child: DropdownButtonFormField(
              //   hint: _machineType[i]["name"] == null ||
              //           _machineType[i]["name"] == ""
              //       ? Text('M??quina Agr??cola ${i}',
              //           style: TextStyle(
              //               color: Color.fromARGB(255, 0, 0, 1),
              //               fontSize: 15,
              //               fontStyle: FontStyle.normal,
              //               fontWeight: FontWeight.w400,
              //               fontFamily: "RobotoFlex"))
              //       : Text(
              //           _machineType[i]["name"],
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
              //       labelText: 'M??quina Agr??cola ${i}'),
              //   isExpanded: true,
              //   iconSize: 30.0,
              //   style: TextStyle(
              //       color: Color.fromARGB(255, 0, 0, 1),
              //       fontSize: 15,
              //       fontStyle: FontStyle.normal,
              //       fontWeight: FontWeight.w400,
              //       fontFamily: "RobotoFlex"),
              //   items: _machineList.map(
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
              //         Map currentMachine = machinesInfo
              //             .where((element) => element["name"] == val.toString())
              //             .first;

              //         _machineType[i]["name"] = val.toString();
              //         _machineType[i]["key"] = currentMachine["key"];
              //       },
              //     );
              //   },
              // )
              child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: TextDropdownFormField(
                    options: _machineList,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Preencha uma M??quina';
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
                        labelText: _machineType[i]["name"] == null ||
                                _machineType[i]["name"] == ''
                            ? 'M??quina ${i}'
                            : _machineType[i]["name"]),
                    dropdownHeight: 420,
                    onChanged: (dynamic val) {
                      setState(
                        () {
                          Map currentMachine = machinesInfo
                              .where((element) =>
                                  element["name"] == val.toString())
                              .first;

                          _machineType[i]["name"] = val.toString();
                          _machineType[i]["key"] = currentMachine["key"];
                        },
                      );
                    },
                  ))),
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
                        Text("M??quinas Agr??colas",
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

                // Padding(
                //     padding: EdgeInsets.only(left: 15, right: 32, top: 5),
                //     child: CheckboxListTile(
                //       title: Text("Outro(a)"),
                //       activeColor: Color.fromARGB(255, 27, 75, 27),
                //       value: _hasOtherMachine,
                //       onChanged: (newValue) {
                //         setState(() {
                //           _hasOtherMachine = newValue!;
                //           _hasOtherMachine
                //               ? _numberInput = 1
                //               : _numberInput = 0;
                //         });
                //       },
                //       controlAffinity: ListTileControlAffinity
                //           .leading, //  <-- leading Checkbox
                //     )),

                // Padding(
                //   padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                //   child: _otherMachine(),
                // ),

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
                        '+ M??quina Agr??cola',
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
                        '- Remover M??quinas',
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
