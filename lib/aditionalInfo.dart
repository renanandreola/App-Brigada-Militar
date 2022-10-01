import 'package:app_brigada_militar/initialPage.dart';
import 'package:flutter/material.dart';

class AditionalInfo extends StatefulWidget {
  const AditionalInfo({Key? key}) : super(key: key);

  @override
  State<AditionalInfo> createState() => _AditionalInfoState();
}

class _AditionalInfoState extends State<AditionalInfo> {
  TextEditingController _department = TextEditingController();

  bool _usedProgram = false;
  bool _usedProgramSuccess = false;

  void _savePropertie() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => InitialPage()));
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
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),

                // Department
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 5),
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

                // Já usou o programa para alguma urgência / emergência?
                Padding(
                    padding: EdgeInsets.only(left: 5, right: 32, top: 5),
                    child: CheckboxListTile(
                      title: Text("Obteve êxito na solicitação"),
                      activeColor: Color.fromARGB(255, 27, 75, 27),
                      value: _usedProgramSuccess,
                      onChanged: (newValue) {
                        setState(() {
                          _usedProgramSuccess = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),

                // History
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 32, top: 5),
                  child: Text("Histórico",
                      style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 120, 120, 120),
                          fontFamily: "RobotoFlex")),
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

                // Save
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 35),
                  child: ElevatedButton(
                    child: Text(
                      'Salvar Propriedade',
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
