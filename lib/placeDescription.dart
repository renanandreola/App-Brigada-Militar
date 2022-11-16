import 'package:app_brigada_militar/aditionalInfo.dart';
import 'package:app_brigada_militar/vehicle.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class PlaceDescription extends StatefulWidget {
  // const PlaceDescription({Key? key}) : super(key: key);
  Map formData;
  PlaceDescription(this.formData);

  @override
  State<PlaceDescription> createState() => _PlaceDescriptionState();
}

class _PlaceDescriptionState extends State<PlaceDescription> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _quantityDefensive = TextEditingController();
  TextEditingController _gunPlaceDescription = TextEditingController();

  bool _hasDefensive = false;
  bool _hasGun = false;
  bool _hasGunPlace = false;
  bool _hasVehicle = false;
  int numberDefensives = 0;
  int numberGun = 0;

  void _goToAdditionalInfoOrVehicle() {
    if (_hasDefensive) {
      if (_formKey.currentState!.validate()) {
        // Retrieve form data
        Map formData = widget.formData;

        // Set new form data
        Map pageFormData = {
          'qty_agricultural_defensives': int.tryParse(_quantityDefensive.text),
          'has_gun': _hasGun,
          'has_gun_local': _hasGunPlace,
          'gun_local_description': _gunPlaceDescription.text,
        };

        // Merge form
        formData.addAll(pageFormData);

        if (_hasVehicle) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Vehicle(formData)));
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AditionalInfo(formData)));
        }
      }
    } else {
      // Retrieve form data
      Map formData = widget.formData;

      // Set new form data
      Map pageFormData = {
        'qty_agricultural_defensives': int.tryParse(_quantityDefensive.text),
        'has_gun': _hasGun,
        'has_gun_local': _hasGunPlace,
        'gun_local_description': _gunPlaceDescription.text,
      };

      // Merge form
      formData.addAll(pageFormData);

      if (_hasVehicle) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Vehicle(formData)));
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AditionalInfo(formData)));
      }
    }
  }

  Widget qtdDefensives() {
    List<Form> filhos = [];
    for (int i = 1; i <= numberDefensives; i++) {
      filhos.add(Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Preencha o número de defensivos agrícolas';
                }
                return null;
              },
              cursorColor: Colors.black,
              decoration: InputDecoration(
                labelText: "Quantidade de defensivos agrícolas",
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
              keyboardType: TextInputType.number,
              controller: _quantityDefensive,
            ),
          ])));
    }
    return Column(
      children: filhos,
    );
  }

  Widget gunInfos() {
    List<Column> filhos = [];
    for (int i = 1; i <= numberGun; i++) {
      filhos.add(Column(
        children: [
          // Possui local adequado para  armazenar a arma de fogo
          Padding(
              padding: EdgeInsets.only(left: 5, right: 32, top: 5),
              child: CheckboxListTile(
                title: Text(
                    "Possui local adequado para  armazenar a arma de fogo"),
                activeColor: Color.fromARGB(255, 27, 75, 27),
                value: _hasGunPlace,
                onChanged: (newValue) {
                  setState(() {
                    _hasGunPlace = newValue!;
                  });
                },
                controlAffinity:
                    ListTileControlAffinity.leading, //  <-- leading Checkbox
              )),

          // Descrição do local onde a arma está armazenada
          Padding(
            padding: EdgeInsets.only(left: 30, right: 32, top: 5),
            child: Text("Descrição do local onde a arma está armazenada",
                style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 120, 120, 120),
                    fontFamily: "RobotoFlex")),
          ),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 32, top: 10),
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
                controller: _gunPlaceDescription,
              ),
            ),
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
                        Text("Descrição do Local",
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),

                // Mantém defensivo(s) agrícola(s)
                Padding(
                    padding: EdgeInsets.only(left: 5, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text("Mantém defensivo(s) agrícola(s)"),
                      activeColor: Color.fromARGB(255, 27, 75, 27),
                      value: _hasDefensive,
                      onChanged: (newValue) {
                        setState(() {
                          _hasDefensive = newValue!;
                          _hasDefensive
                              ? numberDefensives = 1
                              : numberDefensives = 0;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),

                // Show defensives
                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 5),
                    child: qtdDefensives()),

                // Mantém arma de fogo na residência
                Padding(
                    padding: EdgeInsets.only(left: 5, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text("Mantém arma de fogo na residência"),
                      activeColor: Color.fromARGB(255, 27, 75, 27),
                      value: _hasGun,
                      onChanged: (newValue) {
                        setState(() {
                          _hasGun = newValue!;
                          _hasGun ? numberGun = 1 : numberGun = 0;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),

                // Show gun infos
                Padding(
                    padding: EdgeInsets.only(left: 0, right: 32, top: 5),
                    child: gunInfos()),

                // Possui veículo
                Padding(
                    padding: EdgeInsets.only(left: 5, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text("Possui veículo"),
                      activeColor: Color.fromARGB(255, 27, 75, 27),
                      value: _hasVehicle,
                      onChanged: (newValue) {
                        setState(() {
                          _hasVehicle = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),
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
                    onPressed: _goToAdditionalInfoOrVehicle,
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
