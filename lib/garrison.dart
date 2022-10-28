import 'package:app_brigada_militar/home.dart';
import 'package:flutter/material.dart';

class Garrison extends StatefulWidget {
  // const Garrison({Key? key}) : super(key: key);
  late String userName;
  Garrison(this.userName);

  @override
  State<Garrison> createState() => _GarrisonState();
}

class _GarrisonState extends State<Garrison> {
  TextEditingController _codeVTR = TextEditingController();

  List _peopleType = [];
  int numberPeople = 0;

  // Go to initial menu
  void gotoInitialMenu() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => HomeApp(widget.userName)));
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
      numberPeople -= 1;
    });
  }

  // Show the dropdown on click '+ Máquinas Agrícolas'
  Widget peopleWidget() {
    List<Row> filhos = [];
    for (int i = 0; i <= numberPeople; i++) {
      if (_peopleType.length - 1 < i) {
        _peopleType.add("");
      }
      filhos.add(Row(
        children: [
          Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: DropdownButtonFormField(
                hint: _peopleType[i] == null || _peopleType[i] == ""
                    ? Text('Servidor ${i}',
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 1),
                            fontSize: 15,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            fontFamily: "RobotoFlex"))
                    : Text(
                        _peopleType[i],
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
                items: ['Pessoa 1', 'Pessoa 2', 'Pessoa 3'].map(
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
                      _peopleType[i] = val.toString();
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
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 177, 177, 177)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 177, 177, 177)),
                    ),
                  ),
                  keyboardType: TextInputType.name,
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
          ),
        ),
      )),
    );
  }
}
