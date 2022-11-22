import 'dart:developer';

import 'package:app_brigada_militar/newProperty.dart';
import 'package:flutter/material.dart';

class Owner extends StatefulWidget {
  // const Owner({super.key});
  late String userName;
  Owner(this.userName);

  @override
  State<Owner> createState() => _OwnerState();
}

class _OwnerState extends State<Owner> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _respName = TextEditingController();
  TextEditingController _respLastName = TextEditingController();
  TextEditingController _respCPF = TextEditingController();
  TextEditingController _respPhone1 = TextEditingController();
  TextEditingController? _respPhone2 = TextEditingController();

  void _gotoNewProperty() {
    if (_formKey.currentState!.validate()) {
      // Create new form data
      Map formData = {
        'firstname': _respName.text,
        'lastname': _respLastName.text,
        'cpf': _respCPF.text,
        'phone1': _respPhone1.text,
        'phone2': _respPhone2 != null ? _respPhone2!.text : null
      };

      inspect(formData);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NewProperty(formData, widget.userName)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: new Center(
        //     child: new Text('NOVO RUMO', textAlign: TextAlign.center)),
        title: Text("Novo Proprietário"),
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
                        Text("Novo Proprietário",
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),
                Form(
                    key: _formKey,
                    child: Column(children: [
                      // ResponsibleName
                      Padding(
                        padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Preencha o nome do responsável';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            labelText: "Nome do Responsável",
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
                          controller: _respName,
                        ),
                      ),

                      // ResponsibleLastname
                      Padding(
                        padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Preencha o sobrenome do responsável';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            labelText: "Sobrenome do Responsável",
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
                          controller: _respLastName,
                        ),
                      ),

                      // Reponsible CPF
                      Padding(
                        padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Preencha o CPF do responsável';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            labelText: "CPF",
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
                          // keyboardType: TextInputType.name,
                          keyboardType: TextInputType.number,
                          controller: _respCPF,
                        ),
                      ),

                      // Reponsible Phone1
                      Padding(
                        padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Preencha o Telefone 1 do responsável';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            labelText: "Telefone 1",
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
                          // keyboardType: TextInputType.name,
                          keyboardType: TextInputType.number,
                          controller: _respPhone1,
                        ),
                      ),

                      // Reponsible Phone2
                      Padding(
                        padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                        child: TextFormField(
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            labelText: "Telefone 2",
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
                          // keyboardType: TextInputType.name,
                          keyboardType: TextInputType.number,
                          controller: _respPhone2,
                        ),
                      ),

                      // Login
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
                          onPressed: _gotoNewProperty,
                        ),
                      ),
                    ])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
