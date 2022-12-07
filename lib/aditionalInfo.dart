import 'dart:convert';
import 'dart:developer';

import 'package:app_brigada_militar/confirmVisit.dart';
import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/models/Owner.dart';
import 'package:app_brigada_militar/database/models/Property.dart';
import 'package:app_brigada_militar/database/models/PropertyType.dart';
import 'package:app_brigada_militar/database/utils/datetimeToStr.dart';
import 'package:app_brigada_militar/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class AditionalInfo extends StatefulWidget {
  // const AditionalInfo({Key? key}) : super(key: key);
  Map formData;
  late String userName;
  AditionalInfo(this.formData, this.userName);

  @override
  State<AditionalInfo> createState() => _AditionalInfoState();
}

class _AditionalInfoState extends State<AditionalInfo> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _department = TextEditingController();
  TextEditingController _observations = TextEditingController();
  TextEditingController _history = TextEditingController();

  bool _usedProgram = false;
  bool _usedProgramSuccess = false;
  int numberServices = 0;

  // Save propertie
  void _savePropertie() async {
    if (_usedProgram) {
      if (_formKey.currentState!.validate()) {
        // Retrieve form data
        Map formData = widget.formData;

        // Set new form data
        Map pageFormData = {"observations": _observations.text, "history": _history.text};

        // Merge form
        formData.addAll(pageFormData);

        inspect(formData);

        //Create a transaction to avoid atomicity errors
        final db = await DB.instance.database;

        Property? property = null;

        await db.transaction((txn) async {
          // First add the owner
          Owner owner = new Owner(
              firstname: formData["firstname"],
              lastname: formData["lastname"],
              cpf: formData["cpf"],
              phone1: formData["phone1"],
              phone2: formData["phone2"]);
          owner.id = await owner.save(transaction: txn);

          // Get property type
          List<PropertyType> propertyTypes = await PropertyTypesTable()
              .find(name: formData["property_type"], transaction: txn);
          PropertyType propertyType = propertyTypes[0];

          // Add the property
          property = new Property(
              qty_people: int.tryParse(formData["qty_people"]),
              has_geo_board: formData["has_geo_board"],
              has_cams: formData["has_cams"],
              has_phone_signal: formData["has_phone_signal"],
              has_internet: formData["has_internet"],
              has_gun: formData["has_gun"],
              has_gun_local: formData["has_gun_local"],
              gun_local_description: formData["gun_local_description"],
              qty_agricultural_defensives:
                  formData["qty_agricultural_defensives"],
              area: formData["area"],
              observations: formData["observations"],
              latitude: formData["latitude"],
              longitude: formData["longitude"],
              fk_owner_id: owner.id!,
              fk_property_type_id: propertyType.id!);

          property!.id = await property!.save(transaction: txn);

          String property_id = property!.id!;

          final DateTime now = DateTime.now();
          String datetimeStr = datetimeToStr(now);

          //Vehicles
          var vehicles = await SessionManager().get('vehicles');

          if (vehicles != null) {
            for (var vehicle in vehicles) {

              // New vehicle
              if (vehicle["key"] == "0") {
                await txn.insert('vehicles', {
                  'name': vehicle["name"],
                  'brand': vehicle["brand"],
                  "updatedAt": datetimeStr,
                  "createdAt": datetimeStr
                });

                List<Map> vehicles_list = await txn.query('vehicles', where: "name = '${vehicle["name"]}' AND brand = '${vehicle["brand"]}'");
                Map vehicle_insert = vehicles_list[0];
                vehicle["key"] = vehicle_insert["_id"];

                await txn.insert('database_updates',
                {'reference_table': 'vehicles', 'updated_id': vehicle_insert["_id"]});
              }

              Map<String, dynamic> vehiclesMap = {
                "fk_property_id": property_id,
                "fk_vehicle_id": vehicle["key"],
                "color": vehicle["color"],
                "identification": vehicle["identification"],
                "updatedAt": datetimeStr,
                "createdAt": datetimeStr
              };

              await txn.insert('property_vehicles', vehiclesMap);

              String vehicle_key = vehicle["key"];

              String table = 'property_vehicles';
              List<Map> list = await txn.query(table,
                  where:
                      "fk_property_id = '${property_id}' AND fk_vehicle_id = '${vehicle_key}'",
                  orderBy: "createdAt DESC",
                  limit: 1);
              Map elem = list[0];
              await txn.insert('database_updates',
                  {'reference_table': table, 'updated_id': elem["_id"]});
            }
          }

          //Agricultural Machines
          var machines = await SessionManager().get('machines');

          if (machines != null) {
            for (var machine in machines) {
              Map<String, dynamic> machinesMap = {
                "fk_property_id": property_id,
                "fk_agricultural_machine_id": machine["key"],
                "updatedAt": datetimeStr,
                "createdAt": datetimeStr
              };

              txn.insert('property_agricultural_machines', machinesMap);

              String table = 'property_agricultural_machines';
              List<Map> list = await txn.query(table,
                  where:
                      "fk_property_id = '${property_id}' AND fk_agricultural_machine_id = '${machine["key"]}'",
                  orderBy: "createdAt DESC",
                  limit: 1);
              Map elem = list[0];
              await txn.insert('database_updates',
                  {'reference_table': table, 'updated_id': elem["_id"]});
            }
          }

          //Create request if necessary
          if (_usedProgram) {
            Map<String, dynamic> requestModelMap = {
              "agency": _department.text,
              "has_success": _usedProgramSuccess,
              "fk_property_id": property_id,
              "updatedAt": datetimeStr,
              "createdAt": datetimeStr
            };

            inspect(requestModelMap);

            await txn.insert('requests', requestModelMap);

            String table = 'requests';
            List<Map> list = await txn.query(table,
                where:
                    "fk_property_id = '${property_id}' AND agency = '${_department.text}'",
                orderBy: "createdAt DESC",
                limit: 1);
            Map elem = list[0];
            await txn.insert('database_updates',
                {'reference_table': table, 'updated_id': elem["_id"]});
          }
        });

        print("Propriedade Salva com Sucesso!");

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ConfirmVisit(property!.id, widget.userName, widget.formData["history"])));
      }
    } else {
      // Retrieve form data
      Map formData = widget.formData;

      // Set new form data
      Map pageFormData = {"observations": _observations.text, "history": _history.text};

      // Merge form
      formData.addAll(pageFormData);

      inspect(formData);

      //Create a transaction to avoid atomicity errors
      final db = await DB.instance.database;

      Property? property = null;

      await db.transaction((txn) async {
        // First add the owner
        Owner owner = new Owner(
            firstname: formData["firstname"],
            lastname: formData["lastname"],
            cpf: formData["cpf"],
            phone1: formData["phone1"],
            phone2: formData["phone2"]);
        owner.id = await owner.save(transaction: txn);

        // Get property type
        List<PropertyType> propertyTypes = await PropertyTypesTable()
            .find(name: formData["property_type"], transaction: txn);
        PropertyType propertyType = propertyTypes[0];

        // Add the property
        property = new Property(
            qty_people: int.tryParse(formData["qty_people"]),
            has_geo_board: formData["has_geo_board"],
            has_cams: formData["has_cams"],
            has_phone_signal: formData["has_phone_signal"],
            has_internet: formData["has_internet"],
            has_gun: formData["has_gun"],
            has_gun_local: formData["has_gun_local"],
            gun_local_description: formData["gun_local_description"],
            qty_agricultural_defensives:
                formData["qty_agricultural_defensives"].toString(),
            area: formData["area"].toString(),
            observations: formData["observations"],
            latitude: formData["latitude"],
            longitude: formData["longitude"],
            fk_owner_id: owner.id!,
            fk_property_type_id: propertyType.id!);

        property!.id = await property!.save(transaction: txn);

        String property_id = property!.id!;

        final DateTime now = DateTime.now();
        String datetimeStr = datetimeToStr(now);

        //Vehicles
        var vehicles = await SessionManager().get('vehicles');

        if (vehicles != null) {
          for (var vehicle in vehicles) {
            // New vehicle
            if (vehicle["key"] == "0") {
              await txn.insert('vehicles', {
                'name': vehicle["name"],
                'brand': vehicle["brand"],
                "updatedAt": datetimeStr,
                "createdAt": datetimeStr
              });

              List<Map> vehicles_list = await txn.query('vehicles', where: "name = '${vehicle["name"]}' AND brand = '${vehicle["brand"]}'");
              Map vehicle_insert = vehicles_list[0];
              vehicle["key"] = vehicle_insert["_id"];

              await txn.insert('database_updates',
                {'reference_table': 'vehicles', 'updated_id': vehicle_insert["_id"]});
            }

            Map<String, dynamic> vehiclesMap = {
              "fk_property_id": property_id,
              "fk_vehicle_id": vehicle["key"],
              "color": vehicle["color"],
              "identification": vehicle["identification"],
              "updatedAt": datetimeStr,
              "createdAt": datetimeStr
            };

            txn.insert('property_vehicles', vehiclesMap);

            String vehicle_key = vehicle["key"];

            String table = 'property_vehicles';
            List<Map> list = await txn.query(table,
                where:
                    "fk_property_id = '${property_id}' AND fk_vehicle_id = '${vehicle_key}'",
                orderBy: "createdAt DESC",
                limit: 1);
            Map elem = list[0];
            await txn.insert('database_updates',
                {'reference_table': table, 'updated_id': elem["_id"]});
          }
        }

        //Agricultural Machines
        var machines = await SessionManager().get('machines');

        if (machines != null) {
          for (var machine in machines) {
            Map<String, dynamic> machinesMap = {
              "fk_property_id": property_id,
              "fk_agricultural_machine_id": machine["key"],
              "updatedAt": datetimeStr,
              "createdAt": datetimeStr
            };

            txn.insert('property_agricultural_machines', machinesMap);

            String table = 'property_agricultural_machines';
            List<Map> list = await txn.query(table,
                where:
                    "fk_property_id = '${property_id}' AND fk_agricultural_machine_id = '${machine["key"]}'",
                orderBy: "createdAt DESC",
                limit: 1);
            Map elem = list[0];
            await txn.insert('database_updates',
                {'reference_table': table, 'updated_id': elem["_id"]});
          }
        }

        //Create request if necessary
        if (_usedProgram) {
          Map<String, dynamic> requestModelMap = {
            "agency": _department.text,
            "has_success": _usedProgramSuccess,
            "fk_property_id": property_id,
            "updatedAt": datetimeStr,
            "createdAt": datetimeStr
          };

          inspect(requestModelMap);

          await txn.insert('requests', requestModelMap);

          String table = 'requests';
          List<Map> list = await txn.query(table,
              where:
                  "fk_property_id = '${property_id}' AND agency = '${_department.text}'",
              orderBy: "createdAt DESC",
              limit: 1);
          Map elem = list[0];
          await txn.insert('database_updates',
              {'reference_table': table, 'updated_id': elem["_id"]});
        }
      });

      print("Propriedade Salva com Sucesso!");

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ConfirmVisit(property!.id, widget.userName, widget.formData["history"])));
    }
  }

  // show departments info when select 'Já usou o programa para alguma urgência / emergência?'
  Widget servicesInfo() {
    List<Column> filhos = [];
    for (int i = 1; i <= numberServices; i++) {
      filhos.add(Column(
        children: [
          Form(
              key: _formKey,
              child: Column(children: [
                // Department
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 32, top: 5),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Preencha o órgão solicitado';
                      }
                      return null;
                    },
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: "Órgão solicitado",
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
                    keyboardType: TextInputType.name,
                    controller: _department,
                  ),
                ),
              ])),

          // Obteve êxito na solicitação
          Padding(
              padding: EdgeInsets.only(left: 0, right: 32, top: 5),
              child: CheckboxListTile(
                title: Text("Obteve êxito na solicitação"),
                activeColor: Color.fromARGB(255, 27, 75, 27),
                value: _usedProgramSuccess,
                onChanged: (newValue) {
                  setState(() {
                    _usedProgramSuccess = newValue!;
                  });
                },
                controlAffinity:
                    ListTileControlAffinity.leading, //  <-- leading Checkbox
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
        title: Text("Descrição do Local"),
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
                        Text("Informações Adicionais",
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),

                // Já usou o programa para alguma urgência / emergência?
                Padding(
                    padding: EdgeInsets.only(left: 5, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text(
                          "Já usou o programa para alguma urgência / emergência?"),
                      activeColor: Color.fromARGB(255, 27, 75, 27),
                      value: _usedProgram,
                      onChanged: (newValue) {
                        setState(() {
                          _usedProgram = newValue!;
                          _usedProgram
                              ? numberServices = 1
                              : numberServices = 0;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),

                // Department infos
                Padding(
                    padding: EdgeInsets.only(left: 0, right: 32, top: 5),
                    child: servicesInfo()),

                // History
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 32, top: 5),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Informações Adicionais da Propriedade',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 120, 120, 120),
                          fontFamily: "RobotoFlex"),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                            style: BorderStyle.solid)),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      minLines: 5,
                      maxLines: 5,
                      controller: _observations,
                    ),
                  ),
                ),

                // History
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 32, top: 5),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Histórico da Visita',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 120, 120, 120),
                          fontFamily: "RobotoFlex"),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                            style: BorderStyle.solid)),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      minLines: 5,
                      maxLines: 5,
                      controller: _history,
                    ),
                  ),
                ),

                // Save propertie
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
                    onPressed: _savePropertie,
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
