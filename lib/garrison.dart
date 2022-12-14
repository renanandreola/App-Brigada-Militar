import 'dart:convert';
import 'dart:developer';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:app_brigada_militar/database/models/User.dart';
import 'package:app_brigada_militar/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class Garrison extends StatefulWidget {
  // const Garrison({Key? key}) : super(key: key);
  late String userName;
  Garrison(this.userName);

  @override
  State<Garrison> createState() => _GarrisonState();
}

class _GarrisonState extends State<Garrison> {
  TextEditingController _codeVTR = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<Map<String?, String?>> _peopleType = [];
  int numberPeople = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getUserList();
  }

  List<Map<String?, String?>> usersInfo = [];
  List<String> usersList = [];

  _getUserList() async {
    List<User> users = await UsersTable().find();

    List<String> list = [];
    for (User user in users) {
      usersInfo.add({"name": user.name, "key": user.id});
      list.add(user.name!);
    }

    Map user = await SessionManager().get('user');

    setState(() {
      _peopleType[0]["name"] = user["name"];
      _peopleType[0]["key"] = user["_id"];
      usersList = list;

      usersList.map(
        (val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Text(val),
          );
        },
      ).toList();
    });
  }

  // Go to initial menu
  void gotoInitialMenu() async {
    if (_formKey.currentState!.validate()) {
      // Save garrison in session
      var garrison = jsonEncode(_peopleType);
      var vtr = jsonEncode(_codeVTR.text);

      await SessionManager().set('garrison', garrison);
      await SessionManager().set('vtr', vtr);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guarnição cadastrada com sucesso!')),
      );

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => HomeApp(widget.userName)));
    }
  }

  // Increments the number of people
  void addPeople() {
    setState(() {
      numberPeople += 1;
    });
  }

  // Remove last people
  void removePeople() {
    setState(() {
      if (_peopleType.length > 1) {
        _peopleType.removeLast();
        numberPeople -= 1;
      }
    });
  }

  // Show the dropdown on click '+ Máquinas Agrícolas'
  Widget peopleWidget() {
    List<Row> filhos = [];
    for (int i = 0; i <= numberPeople; i++) {
      if (_peopleType.length - 1 < i) {
        _peopleType.add({"name": "", "key": ""});
      }
      filhos.add(Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            // child: DropdownButtonFormField(
            //   hint: _peopleType[i]["name"] == null ||
            //           _peopleType[i]["name"] == ""
            //       ? Text('Servidor ${i}',
            //           style: TextStyle(
            //               color: Color.fromARGB(255, 0, 0, 1),
            //               fontSize: 15,
            //               fontStyle: FontStyle.normal,
            //               fontWeight: FontWeight.w400,
            //               fontFamily: "RobotoFlex"))
            //       : Text(
            //           _peopleType[i]["name"]!,
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
            //       labelText: 'Servidor ${i}'),
            //   isExpanded: true,
            //   iconSize: 30.0,
            //   style: TextStyle(
            //       color: Color.fromARGB(255, 0, 0, 1),
            //       fontSize: 15,
            //       fontStyle: FontStyle.normal,
            //       fontWeight: FontWeight.w400,
            //       fontFamily: "RobotoFlex"),
            //   items: usersList.map(
            //     (val) {
            //       return DropdownMenuItem<String>(
            //         value: val,
            //         child: Text(val),
            //       );
            //     },
            //   ).toList(),
            //   onChanged: i != 0
            //       ? (val) {
            //           setState(
            //             () {
            //               Map currentUser = usersInfo
            //                   .where((element) =>
            //                       element["name"] == val.toString())
            //                   .first;
            //               _peopleType[i]["name"] = val.toString();
            //               _peopleType[i]["key"] = currentUser["key"];
            //             },
            //           );
            //         }
            //       : null,
            // )

            child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: TextDropdownFormField(
                  options: usersList,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preencha uma servidor';
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
                      labelText: _peopleType[i]["name"] == null ||
                              _peopleType[i]["name"] == ""
                          ? "Servidor ${i}"
                          : _peopleType[i]["name"]),
                  dropdownHeight: 420,
                  onChanged: i != 0
                      ? (dynamic val) {
                          setState(
                            () {
                              Map currentUser = usersInfo
                                  .where((element) =>
                                      element["name"] == val.toString())
                                  .first;
                              _peopleType[i]["name"] = val.toString();
                              _peopleType[i]["key"] = currentUser["key"];
                            },
                          );
                        }
                      : null,
                )),
          ),
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
        title: Text("NOVO RUMO"),
        backgroundColor: Color.fromARGB(255, 27, 75, 27),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              // Padding(
              //   padding: EdgeInsets.only(top: 0, bottom: 16),
              //   child: Container(
              //     width: double.infinity,
              //     color: Color.fromARGB(255, 27, 75, 27),
              //     child: Text("opa"),
              //   ),
              // ),
              Image.asset('assets/images/rectangle.png'),

              // User Name
              Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                  child: Row(
                    children: [
                      Text("Olá, ",
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.normal,
                              fontFamily: "RobotoFlex")),
                      Text(widget.userName,
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                              fontFamily: "RobotoFlex"))
                    ],
                  )),

              // Text info
              Padding(
                padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Por favor, informe a guarnição da patrulha',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.normal,
                        fontFamily: "RobotoFlex"),
                  ),
                ),
              ),

              // Type of people
              Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 20),
                  child: peopleWidget()),

              // Add new machine
              Padding(
                padding: EdgeInsets.only(left: 32, right: 32, top: 30),
                child: GestureDetector(
                  onTap: () {
                    addPeople();
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      '+ Adicionar Servidor',
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

              // Remove people
              Padding(
                padding: EdgeInsets.only(left: 32, right: 32, top: 30),
                child: GestureDetector(
                  onTap: () {
                    removePeople();
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      '- Remover Servidor',
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
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Code VTR
                      Padding(
                        padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Preencha o código da viatura utilizada';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            labelText: "Viatura Utilizada",
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
                          controller: _codeVTR,
                        ),
                      ),

                      // Login
                      Padding(
                        padding: EdgeInsets.only(left: 32, right: 32, top: 35),
                        child: ElevatedButton(
                          child: Text(
                            'Continuar',
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
                          onPressed: gotoInitialMenu,
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      )),
    );
  }
}
