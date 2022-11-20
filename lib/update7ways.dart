import 'dart:io';

import 'package:app_brigada_militar/initialPage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class Update7ways extends StatefulWidget {
  const Update7ways({Key? key}) : super(key: key);

  @override
  State<Update7ways> createState() => _Update7waysState();
}

class _Update7waysState extends State<Update7ways> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _link = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // updateFiles();
  }

  bool loading = false;
  double progress = 0;
  final Dio dio = Dio();

  Future<bool> saveFile(String url, fileName) async {
    Directory directory;

    try {
      if (await _requestPermission(
          Permission.manageExternalStorage, Permission.storage)) {
        var directory = await getExternalStorageDirectory();
        print(directory!.path);

        String newPath = "";
        List<String> folders = directory.path.split("/");

        for (int x = 1; x < folders.length; x++) {
          String folder = folders[x];

          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }

        newPath = newPath + "/7ways";

        directory = Directory(newPath);
        print(directory.path);

        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        if (await directory.exists()) {
          File saveFile = File(directory.path + "/$fileName");
          await dio.download(url, saveFile.path,
              onReceiveProgress: (downloaded, totalSize) {
            setState(() {
              progress = downloaded / totalSize;
            });
          });

          return true;
        }
      } else {
        return false;
      }
    } catch (e) {
      print(e);
    }

    return false;
  }

  Future<bool> _requestPermission(
      Permission permission, Permission permission2) async {
    if (await permission.isGranted && await permission2.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      var result2 = await permission2.request();

      if (result == PermissionStatus.granted &&
          result2 == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  _downloadFiles() async {
    setState(() {
      loading = true;
    });

    bool downloaded = await saveFile(_link.text, "files.zip");

    if (downloaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atualizado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Houve um erro ao atualizar!')),
      );
    }

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => InitialPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: new Center(
        //     child: new Text('NOVO RUMO', textAlign: TextAlign.center)),
        title: Text("Atualizar 7ways"),
        backgroundColor: Color.fromARGB(255, 27, 75, 27),
      ),
      body: loading
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  Text("Baixando..."),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(
                      color: Colors.green,
                      backgroundColor: Color.fromARGB(255, 188, 194, 188),
                      minHeight: 10,
                      value: progress,
                    ),
                  )
                ]))
          : Center(
              child: Column(
                children: [
                  // Color bar
                  Image.asset('assets/images/rectangle.png'),

                  // Title
                  Padding(
                      padding: EdgeInsets.only(left: 32, right: 32, top: 20),
                      child: Row(
                        children: [
                          Text("Atualizar 7ways",
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
                          padding:
                              EdgeInsets.only(left: 32, right: 32, top: 10),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Preencha a URL';
                              }
                              return null;
                            },
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              labelText: "URL",
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
                            controller: _link,
                          ),
                        ),

                        // Login
                        Padding(
                          padding:
                              EdgeInsets.only(left: 32, right: 32, top: 35),
                          child: ElevatedButton(
                            child: Text(
                              'Baixar',
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
                            onPressed: _downloadFiles,
                          ),
                        ),
                      ])),
                ],
              ),
            ),
    );
  }
}
