import 'package:flutter/material.dart';

class EditMachines extends StatefulWidget {
  // const EditMachines({Key? key}) : super(key: key);
  Map formData;
  EditMachines(this.formData);

  @override
  State<EditMachines> createState() => _EditMachinesState();
}

class _EditMachinesState extends State<EditMachines> {
  // String _machineType0 = '';

  // String _machineType1 = '';
  List _machineType = [];
  int numberMachines = 0;

  // Increments the number of machines on click '+ Máquinas Agrícolas'
  void addNewMachine() {
    setState(() {
      numberMachines += 1;
    });
  }

  // Go to page that have the description of the place
  void _goToPlaceDescription() {
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => PlaceDescription(widget.formData)));
  }

  // Show the dropdown on click '+ Máquinas Agrícolas'
  Widget machineType1() {
    List<DropdownButtonFormField> filhos = [];
    for (int i = 0; i <= numberMachines; i++) {
      if (_machineType.length - 1 < i) {
        _machineType.add("");
      }
      filhos.add(DropdownButtonFormField(
        hint: _machineType[i] == null || _machineType[i] == ""
            ? Text('Máquina Agrícola ${i}',
                style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 1),
                    fontSize: 15,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                    fontFamily: "RobotoFlex"))
            : Text(
                _machineType[i],
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
            labelText: 'Máquina Agrícola ${i}'),
        isExpanded: true,
        iconSize: 30.0,
        style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 1),
            fontSize: 15,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w400,
            fontFamily: "RobotoFlex"),
        items: [
          'MF4707 - Massey Ferguson 1',
          'MF4707 - Massey Ferguson 2',
          'MF4707 - Massey Ferguson 3'
        ].map(
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
              _machineType[i] = val.toString();
            },
          );
        },
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
        title: Text("Editar propriedade"),
        backgroundColor: Color.fromARGB(255, 27, 75, 27),
        leading: GestureDetector(
          onTap: () {/* Write listener code here */},
          child: Icon(
            Icons.menu,
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
                        Text("Editar Máquinas Agrícolas",
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontFamily: "RobotoFlex")),
                      ],
                    )),

                // Type of machines
                Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, top: 20),
                    child: machineType1()),

                // Add new machine
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 30),
                  child: GestureDetector(
                    onTap: () {
                      addNewMachine();
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        '+ Máquina Agrícola',
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

                // Next Page
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
                    onPressed: _goToPlaceDescription,
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
