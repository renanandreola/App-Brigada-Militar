import 'package:app_brigada_militar/initialPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class LogOut extends StatefulWidget {
  const LogOut({Key? key}) : super(key: key);

  @override
  State<LogOut> createState() => _LogOutState();
}

class _LogOutState extends State<LogOut> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _logout();
  }

  _logout() async {
    await SessionManager().remove("user");
    await SessionManager().remove("garrison");

    Navigator.push(context,
          MaterialPageRoute(builder: (context) => InitialPage()));
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
                  child: Text("Logout",
                      style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          fontFamily: "RobotoFlex"))),
            ],
          ),
        ),
      )),
    );
  }
}
