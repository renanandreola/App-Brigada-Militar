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
  int numberServices = 0;

  // Save propertie
  void _savePropertie() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => InitialPage()));
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
