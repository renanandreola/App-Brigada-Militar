import 'dart:convert';
import 'dart:developer';

import 'package:app_brigada_militar/confirmVisit.dart';
import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/models/Owner.dart';
import 'package:app_brigada_militar/database/models/Property.dart';
import 'package:app_brigada_militar/database/models/PropertyType.dart';
import 'package:app_brigada_militar/home.dart';
import 'package:flutter/material.dart';

class AditionalInfo extends StatefulWidget {
  // const AditionalInfo({Key? key}) : super(key: key);
  Map formData;
  AditionalInfo(this.formData);

  @override
  State<AditionalInfo> createState() => _AditionalInfoState();
}

class _AditionalInfoState extends State<AditionalInfo> {
  TextEditingController _department = TextEditingController();

  bool _usedProgram = false;
  bool _usedProgramSuccess = false;
  int numberServices = 0;

  // Save propertie
  void _savePropertie() async {
    // Retrieve form data
    Map formData = widget.formData;

    // // Set new form data information
    // Map pageFormData = {
    // };

    // // Merge form
    // formData.addAll(pageFormData);

    inspect(formData);

    //Create a transaction to avoid atomicity errors
    final db = await DB.instance.database;

    await db.transaction((txn) async {
      // First add the owner
      Owner owner = new Owner(
          firstname: formData["firstname"], lastname: formData["lastname"]);
      owner.id = await owner.save(transaction: txn);

      // Get property type
      List<PropertyType> propertyTypes = await PropertyTypesTable()
          .find(name: formData["property_type"], transaction: txn);
      PropertyType propertyType = propertyTypes[0];

      // Add the property
      Property property = new Property(
          qty_people: int.tryParse(formData["qty_people"]),
          has_geo_board: formData["has_geo_board"] == 1,
          has_cams: formData["has_cams"] == 1,
          has_phone_signal: formData["has_phone_signal"] == 1,
          has_internet: formData["has_internet"] == 1,
          has_gun: formData["has_gun"] == 1,
          has_gun_local: formData["has_gun_local"] == 1,
          gun_local_description: formData["gun_local_description"],
          qty_agricultural_defensives: formData["qty_agricultural_defensives"],
          observations: formData["observations"],
          fk_owner_id: owner.id!,
          fk_property_type_id: propertyType.id!);

      property.id = await property.save(transaction: txn);
    });

    print("Propriedade Salva com Sucesso!");

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ConfirmVisit()));
  }

  // show departments info when select 'Já usou o programa para alguma urgência / emergência?'
  Widget servicesInfo() {
    List<Column> filhos = [];
    for (int i = 1; i <= numberServices; i++) {
      filhos.add(Column(
        children: [
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
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 177, 177, 177)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 177, 177, 177)),
                ),
              ),
              keyboardType: TextInputType.name,
              controller: _department,
            ),
          ),

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
                      'Histórico',
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
