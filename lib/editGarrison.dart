import 'dart:convert';
import 'dart:developer';

import 'package:app_brigada_militar/confirmVisit.dart';
import 'package:app_brigada_militar/database/models/User.dart';
import 'package:app_brigada_militar/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class EditGarrison extends StatefulWidget {
  // const Garrison({Key? key}) : super(key: key);
  late String userName;
  late String fromPage;
  EditGarrison(this.userName, this.fromPage);

  @override
  State<EditGarrison> createState() => _EditGarrisonState();
}

class _EditGarrisonState extends State<EditGarrison> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _codeVTR = TextEditingController();

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

    setState(() {
      usersList = list;
    });

    populateScreen();
  }

  populateScreen() async {
    List garrison = await SessionManager().get('garrison');
    var vtr = await SessionManager().get('vtr');

    var i = 0;
    for (var user in garrison) {
      _peopleType.add({"name": "", "key": ""});
      setState(() {
        _peopleType[i]["name"] = user["name"];
        _peopleType[i]["key"] = user["key"];
      });
      i++;
    }

    setState(() {
      _peopleType.removeLast();
      numberPeople = garrison.length - 1;
      _codeVTR.text = vtr;
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

      if (widget.fromPage == 'from_page_confirm') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConfirmVisit(widget.userName)));
        return;
      }

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
              child: DropdownButtonFormField(
                hint: _peopleType[i]["name"] == null ||
                        _peopleType[i]["name"] == ""
                    ? Text('Servidor ${i}',
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 1),
                            fontSize: 15,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            fontFamily: "RobotoFlex"))
                    : Text(
                        _peopleType[i]["name"]!,
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
                    labelText: 'Servidor ${i}'),
                isExpanded: true,
                iconSize: 30.0,
                style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 1),
                    fontSize: 15,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                    fontFamily: "RobotoFlex"),
                items: usersList.map(
                  (val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val),
                    );
                  },
                ).toList(),
                onChanged: i != 0
                    ? (val) {
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
                      Text("Alterar Guarnição",
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.normal,
                              fontFamily: "RobotoFlex")),
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
                  child: Column(children: [
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
                        keyboardType: TextInputType.name,
                        controller: _codeVTR,
                      ),
                    ),
                  ])),

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
          ),
        ),
      )),
    );
  }
}
