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

class EditAditionalInfo extends StatefulWidget {
  // const AditionalInfo({Key? key}) : super(key: key);
  Map formData;
  late String userName;
  EditAditionalInfo(this.formData, this.userName);

  @override
  State<EditAditionalInfo> createState() => _EditAditionalInfoState();
}

class _EditAditionalInfoState extends State<EditAditionalInfo> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    populate();
  }

  populate() async {
    Map property = await SessionManager().get('edit_property');

    final db = await DB.instance.database;
    var property_id = property["_id"];
    List<Map> requests =
        await db.query('requests', where: "fk_property_id = '${property_id}'");
    Map? request = null;

    if (requests.isNotEmpty) {
      request = requests[0];
    }

    setState(() {
      _department.text = requests.isNotEmpty ? request!["agency"] : "";
      _observations.text =
          property["observations"] != 'null' ? property["observations"] : "";
      _usedProgram = requests.isNotEmpty;
      _usedProgramSuccess = requests.isNotEmpty
          ? (request!["has_success"] == true || request["has_success"] == 1)
              ? true
              : false
          : false;
      numberServices = requests.isEmpty ? 0 : 1;
    });
  }

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

        Map property = await SessionManager().get('edit_property');

        await db.transaction((txn) async {
          final DateTime now = DateTime.now();
          String datetimeStr = datetimeToStr(now);

          // First add the owner
          String property_id = property["_id"];

          List<Map> owners = await txn.query('owners',
              where:
                  "firstname = '${formData["firstname"]}' AND lastname = '${formData["lastname"]}'");

          String? owner_id = null;
          if (owners.length > 0) {
            Map owner = owners[0];

            // Update owner
            await txn.update(
                'owners',
                {
                  "_id": owner["_id"],
                  "firstname": formData["firstname"],
                  "lastname": formData["lastname"],
                  "cpf": formData["cpf"],
                  "phone1": formData["phone1"],
                  "phone2": formData["phone2"],
                  "createdAt": owner["createdAt"],
                  "updatedAt": owner["updatedAt"],
                },
                where: "_id = '${owner["_id"]}'");

            owner_id = owner["_id"];
          } else {
            Owner owner = new Owner(
                firstname: formData["firstname"],
                lastname: formData["lastname"],
                cpf: formData["cpf"],
                phone1: formData["phone1"],
                phone2: formData["phone2"]);

            owner.id = await owner.save(transaction: txn);
            owner_id = owner.id;
          }

          String table = 'owners';
          await txn.insert('database_updates',
              {'reference_table': table, 'updated_id': owner_id});

          List<Map> property_types = await txn.query('property_types',
              where: "name = '${formData["property_type"]}'");
          Map property_type = property_types[0];

          String property_type_id = property_type["_id"];

          await txn.update(
              'properties',
              {
                "_id": property["_id"],
                "code": property["code"],
                "has_geo_board": formData["has_geo_board"],
                "qty_people": formData["qty_people"],
                "has_cams": formData["has_cams"],
                "has_phone_signal": formData["has_phone_signal"],
                "has_internet": formData["has_internet"],
                "has_gun": formData["has_gun"],
                "has_gun_local": formData["has_gun_local"],
                "gun_local_description": formData["gun_local_description"],
                "qty_agricultural_defensives":
                    formData["qty_agricultural_defensives"],
                "observations": formData["observations"],
                "latitude": property["latitude"],
                "longitude": property["longitude"],
                "fk_owner_id": owner_id,
                "fk_property_type_id": property_type_id,
                "createdAt": property["createdAt"],
                "updatedAt": property["updatedAt"],
              },
              where: "_id = '${property["_id"]}'");

          table = 'properties';
          await txn.insert('database_updates',
              {'reference_table': table, 'updated_id': property["_id"]});

          //List vehicles
          var vehicles = await SessionManager().get('edit_vehicles');

          if (vehicles != null) {
            //Store in a variable all current property vehicles before save
            List<String> vehicles_ids = [];

            var all_current_vehicles = await txn.query(
              'property_vehicles',
              where: "fk_property_id = '${property_id}'",
            );

            for (var vehicle in all_current_vehicles) {
              vehicles_ids.add(vehicle["fk_vehicle_id"]);
            }

            //Verify each vehicle if it's already in the database (same property and same vehicle)
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

              List<Map> property_vehicles = await txn.query('property_vehicles',
                  where:
                      "fk_vehicle_id = '${vehicle["key"]}' AND fk_property_id = '${property_id}'");
              // if exists
              if (property_vehicles.length > 0) {
                //  ignore and remove id from vehicles_ids
                vehicles_ids.remove(property_vehicles[0]["fk_vehicle_id"]);
              } else {
                // if not exists
                // insert into database
                await txn.insert('property_vehicles', {
                  "color": vehicle["color"],
                  "fk_property_id": property_id,
                  "fk_vehicle_id": vehicle["key"],
                  "identification": vehicle["identification"],
                  "createdAt": datetimeStr,
                  "updatedAt": datetimeStr,
                });

                List<Map> p_vehicles = await txn.query(
                  'property_vehicles',
                  where:
                      "fk_property_id = '${property_id}' AND fk_vehicle_id = '${vehicle["key"]}'",
                );
                Map p_vehicle = p_vehicles[0];

                table = 'property_vehicles';
                await txn.insert('database_updates',
                    {'reference_table': table, 'updated_id': p_vehicle["_id"]});
              }
            }

            //remove all non used vehicles
            for (var id in vehicles_ids) {
              List<Map> p_vehicles = await txn.query(
                'property_vehicles',
                where:
                    "fk_property_id = '${property_id}' AND fk_vehicle_id = '${id}'",
              );
              Map p_vehicle = p_vehicles[0];

              await txn.delete('property_vehicles',
                  where:
                      "fk_property_id = '${property_id}' AND fk_vehicle_id = '${id}'");

              table = 'property_vehicles';
              await txn.insert('garbages',
                  {"reference_table": table, "deleted_id": p_vehicle["_id"]});
            }
          } else {
            List<Map> property_vehicles = await txn.query('property_vehicles',
                where: "fk_property_id = '${property_id}'");

            if (property_vehicles.length > 0) {
              for (var property_vehicle in property_vehicles) {
                table = 'property_vehicles';
                await txn.insert('garbages', {
                  "reference_table": table,
                  "deleted_id": property_vehicle["_id"]
                });

                await txn.delete('property_vehicles',
                    where: "_id = '${property_vehicle["_id"]}'");
              }
            }
          }

          //List Agricultural Machines
          var agricultural_machines =
              await SessionManager().get('edit_agricultural_machines');

          if (agricultural_machines != null) {
            //Store in a variable all current property agricultural machines before save
            List<String> agricultural_machines_ids = [];

            var all_current_agricultural_machines = await txn.query(
              'property_agricultural_machines',
              where: "fk_property_id = '${property_id}'",
            );

            for (var agricultural_machine
                in all_current_agricultural_machines) {
              agricultural_machines_ids
                  .add(agricultural_machine["fk_agricultural_machine_id"]);
            }

            //Verify each agricultural machine if it's already in the database (same property and same agricultural machine)
            for (var agricultural_machine in agricultural_machines) {
              List<Map> property_agricultural_machines = await txn.query(
                  'property_agricultural_machines',
                  where:
                      "fk_agricultural_machine_id = '${agricultural_machine["key"]}' AND fk_property_id = '${property_id}'");
              // if exists
              if (property_agricultural_machines.length > 0) {
                //  ignore and remove id from agricultural_machine_ids
                agricultural_machines_ids.remove(
                    property_agricultural_machines[0]
                        ["fk_agricultural_machine_id"]);
              } else {
                // if not exists
                // insert into database
                await txn.insert('property_agricultural_machines', {
                  "fk_property_id": property_id,
                  "fk_agricultural_machine_id": agricultural_machine["key"],
                  "createdAt": datetimeStr,
                  "updatedAt": datetimeStr,
                });

                List<Map> p_agricultural_machines = await txn.query(
                  'property_agricultural_machines',
                  where:
                      "fk_property_id = '${property_id}' AND fk_agricultural_machine_id = '${agricultural_machine["key"]}'",
                );
                Map p_agricultural_machine = p_agricultural_machines[0];

                table = 'property_agricultural_machines';
                await txn.insert('database_updates', {
                  'reference_table': table,
                  'updated_id': p_agricultural_machine["_id"]
                });
              }
            }

            //remove all non used agricultural amchines
            for (var id in agricultural_machines_ids) {
              List<Map> p_agricultural_machines = await txn.query(
                'property_agricultural_machines',
                where:
                    "fk_property_id = '${property_id}' AND fk_agricultural_machine_id = '${id}'",
              );
              Map p_agricultural_machine = p_agricultural_machines[0];

              await txn.delete('property_agricultural_machines',
                  where:
                      "fk_property_id = '${property_id}' AND fk_agricultural_machine_id = '${id}'");

              table = 'property_agricultural_machines';
              await txn.insert('garbages', {
                "reference_table": table,
                "deleted_id": p_agricultural_machine["_id"]
              });
            }
          } else {
            List<Map> property_agricultural_machines = await txn.query(
                'property_agricultural_machines',
                where: "fk_property_id = '${property_id}'");

            if (property_agricultural_machines.length > 0) {
              for (var property_agricultural_machine
                  in property_agricultural_machines) {
                table = 'property_agricultural_machines';
                await txn.insert('garbages', {
                  "reference_table": table,
                  "deleted_id": property_agricultural_machine["_id"]
                });

                await txn.delete('property_agricultural_machines',
                    where: "_id = '${property_agricultural_machine["_id"]}'");
              }
            }
          }
        });

        // print("Propriedade Salva com Sucesso!");

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ConfirmVisit(property["_id"], widget.userName, widget.formData["history"])));
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

      Map property = await SessionManager().get('edit_property');

      await db.transaction((txn) async {
        final DateTime now = DateTime.now();
        String datetimeStr = datetimeToStr(now);

        // First add the owner
        String property_id = property["_id"];

        List<Map> owners = await txn.query('owners',
            where:
                "firstname = '${formData["firstname"]}' AND lastname = '${formData["lastname"]}'");

        String? owner_id = null;
        if (owners.length > 0) {
          Map owner = owners[0];

          // Update owner
          await txn.update(
              'owners',
              {
                "_id": owner["_id"],
                "firstname": formData["firstname"],
                "lastname": formData["lastname"],
                "cpf": formData["cpf"],
                "phone1": formData["phone1"],
                "phone2": formData["phone2"],
                "createdAt": owner["createdAt"],
                "updatedAt": owner["updatedAt"],
              },
              where: "_id = '${owner["_id"]}'");

          owner_id = owner["_id"];
        } else {
          Owner owner = new Owner(
              firstname: formData["firstname"],
              lastname: formData["lastname"],
              cpf: formData["cpf"],
              phone1: formData["phone1"],
              phone2: formData["phone2"]);

          owner.id = await owner.save(transaction: txn);
          owner_id = owner.id;
        }

        String table = 'owners';
        await txn.insert('database_updates',
            {'reference_table': table, 'updated_id': owner_id});

        List<Map> property_types = await txn.query('property_types',
            where: "name = '${formData["property_type"]}'");
        Map property_type = property_types[0];

        String property_type_id = property_type["_id"];

        await txn.update(
            'properties',
            {
              "_id": property["_id"],
              "code": property["code"],
              "has_geo_board": formData["has_geo_board"],
              "qty_people": formData["qty_people"],
              "has_cams": formData["has_cams"],
              "has_phone_signal": formData["has_phone_signal"],
              "has_internet": formData["has_internet"],
              "has_gun": formData["has_gun"],
              "has_gun_local": formData["has_gun_local"],
              "gun_local_description": formData["gun_local_description"],
              "qty_agricultural_defensives":
                  formData["qty_agricultural_defensives"],
              "area": formData["area"].toString(),
              "observations": formData["observations"],
              "latitude": property["latitude"],
              "longitude": property["longitude"],
              "fk_owner_id": owner_id,
              "fk_property_type_id": property_type_id,
              "createdAt": property["createdAt"],
              "updatedAt": property["updatedAt"],
            },
            where: "_id = '${property["_id"]}'");

        table = 'properties';
        await txn.insert('database_updates',
            {'reference_table': table, 'updated_id': property["_id"]});

        //List vehicles
        var vehicles = await SessionManager().get('edit_vehicles');

        if (vehicles != null) {
          //Store in a variable all current property vehicles before save
          List<String> vehicles_ids = [];

          var all_current_vehicles = await txn.query(
            'property_vehicles',
            where: "fk_property_id = '${property_id}'",
          );

          for (var vehicle in all_current_vehicles) {
            vehicles_ids.add(vehicle["fk_vehicle_id"]);
          }

          //Verify each vehicle if it's already in the database (same property and same vehicle)
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

            List<Map> property_vehicles = await txn.query('property_vehicles',
                where:
                    "fk_vehicle_id = '${vehicle["key"]}' AND fk_property_id = '${property_id}'");
            // if exists
            if (property_vehicles.length > 0) {
              //  ignore and remove id from vehicles_ids
              vehicles_ids.remove(property_vehicles[0]["fk_vehicle_id"]);
            } else {
              // if not exists
              // insert into database
              await txn.insert('property_vehicles', {
                "color": vehicle["color"],
                "fk_property_id": property_id,
                "fk_vehicle_id": vehicle["key"],
                "identification": vehicle["identification"],
                "createdAt": datetimeStr,
                "updatedAt": datetimeStr,
              });

              List<Map> p_vehicles = await txn.query(
                'property_vehicles',
                where:
                    "fk_property_id = '${property_id}' AND fk_vehicle_id = '${vehicle["key"]}'",
              );
              Map p_vehicle = p_vehicles[0];

              table = 'property_vehicles';
              await txn.insert('database_updates',
                  {'reference_table': table, 'updated_id': p_vehicle["_id"]});
            }
          }

          //remove all non used vehicles
          for (var id in vehicles_ids) {
            List<Map> p_vehicles = await txn.query(
              'property_vehicles',
              where:
                  "fk_property_id = '${property_id}' AND fk_vehicle_id = '${id}'",
            );
            Map p_vehicle = p_vehicles[0];

            await txn.delete('property_vehicles',
                where:
                    "fk_property_id = '${property_id}' AND fk_vehicle_id = '${id}'");

            table = 'property_vehicles';
            await txn.insert('garbages',
                {"reference_table": table, "deleted_id": p_vehicle["_id"]});
          }
        } else {
          List<Map> property_vehicles = await txn.query('property_vehicles',
              where: "fk_property_id = '${property_id}'");

          if (property_vehicles.length > 0) {
            for (var property_vehicle in property_vehicles) {
              table = 'property_vehicles';
              await txn.insert('garbages', {
                "reference_table": table,
                "deleted_id": property_vehicle["_id"]
              });

              await txn.delete('property_vehicles',
                  where: "_id = '${property_vehicle["_id"]}'");
            }
          }
        }

        //List Agricultural Machines
        var agricultural_machines =
            await SessionManager().get('edit_agricultural_machines');

        if (agricultural_machines != null) {
          //Store in a variable all current property agricultural machines before save
          List<String> agricultural_machines_ids = [];

          var all_current_agricultural_machines = await txn.query(
            'property_agricultural_machines',
            where: "fk_property_id = '${property_id}'",
          );

          for (var agricultural_machine in all_current_agricultural_machines) {
            agricultural_machines_ids
                .add(agricultural_machine["fk_agricultural_machine_id"]);
          }

          //Verify each agricultural machine if it's already in the database (same property and same agricultural machine)
          for (var agricultural_machine in agricultural_machines) {
            List<Map> property_agricultural_machines = await txn.query(
                'property_agricultural_machines',
                where:
                    "fk_agricultural_machine_id = '${agricultural_machine["key"]}' AND fk_property_id = '${property_id}'");
            // if exists
            if (property_agricultural_machines.length > 0) {
              //  ignore and remove id from agricultural_machine_ids
              agricultural_machines_ids.remove(property_agricultural_machines[0]
                  ["fk_agricultural_machine_id"]);
            } else {
              // if not exists
              // insert into database
              await txn.insert('property_agricultural_machines', {
                "fk_property_id": property_id,
                "fk_agricultural_machine_id": agricultural_machine["key"],
                "createdAt": datetimeStr,
                "updatedAt": datetimeStr,
              });

              List<Map> p_agricultural_machines = await txn.query(
                'property_agricultural_machines',
                where:
                    "fk_property_id = '${property_id}' AND fk_agricultural_machine_id = '${agricultural_machine["key"]}'",
              );
              Map p_agricultural_machine = p_agricultural_machines[0];

              table = 'property_agricultural_machines';
              await txn.insert('database_updates', {
                'reference_table': table,
                'updated_id': p_agricultural_machine["_id"]
              });
            }
          }

          //remove all non used agricultural amchines
          for (var id in agricultural_machines_ids) {
            List<Map> p_agricultural_machines = await txn.query(
              'property_agricultural_machines',
              where:
                  "fk_property_id = '${property_id}' AND fk_agricultural_machine_id = '${id}'",
            );
            Map p_agricultural_machine = p_agricultural_machines[0];

            await txn.delete('property_agricultural_machines',
                where:
                    "fk_property_id = '${property_id}' AND fk_agricultural_machine_id = '${id}'");

            table = 'property_agricultural_machines';
            await txn.insert('garbages', {
              "reference_table": table,
              "deleted_id": p_agricultural_machine["_id"]
            });
          }
        } else {
          List<Map> property_agricultural_machines = await txn.query(
              'property_agricultural_machines',
              where: "fk_property_id = '${property_id}'");

          if (property_agricultural_machines.length > 0) {
            for (var property_agricultural_machine
                in property_agricultural_machines) {
              table = 'property_agricultural_machines';
              await txn.insert('garbages', {
                "reference_table": table,
                "deleted_id": property_agricultural_machine["_id"]
              });

              await txn.delete('property_agricultural_machines',
                  where: "_id = '${property_agricultural_machine["_id"]}'");
            }
          }
        }
      });

      // print("Propriedade Salva com Sucesso!");

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ConfirmVisit(property["_id"], widget.userName, widget.formData["history"])));
    }
  }

  // show departments info when select 'J?? usou o programa para alguma urg??ncia / emerg??ncia?'
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
                        return 'Preencha o ??rg??o solicitado';
                      }
                      return null;
                    },
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: "??rg??o solicitado",
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

          // Obteve ??xito na solicita????o
          Padding(
              padding: EdgeInsets.only(left: 0, right: 32, top: 5),
              child: CheckboxListTile(
                title: Text("Obteve ??xito na solicita????o"),
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
        title: Text("Descri????o do Local"),
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
                        Text("Informa????es Adicionais",
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),

                // J?? usou o programa para alguma urg??ncia / emerg??ncia?
                Padding(
                    padding: EdgeInsets.only(left: 5, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text(
                          "J?? usou o programa para alguma urg??ncia / emerg??ncia?"),
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
                      'Informa????es Adicionais da Propriedade',
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
                      'Hist??rico da Visita',
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
