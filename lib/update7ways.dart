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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    updateFiles();
  }

  bool loading = false;
  double progress = 0;
  final Dio dio = Dio();

  Future<bool> saveFile(String url, fileName) async {
    Directory directory;

    try {
      if (await _requestPermission(Permission.manageExternalStorage, Permission.storage)) {
        var directory = await getExternalStorageDirectory();
        print(directory!.path);

        String newPath = "";
        List<String> folders = directory!.path.split("/");

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

  Future<bool> _requestPermission(Permission permission, Permission permission2) async {
    if (await permission.isGranted && await permission2.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      var result2 = await permission2.request();

      if (result == PermissionStatus.granted && result2 == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  updateFiles() async {
    setState(() {
      loading = true;
    });

    bool downloaded = await saveFile(
        "https://novo-rumo-api.herokuapp.com/7ways/file.txt", "file.txt");

    if (downloaded) {
      print("File Downloaded");
    } else {
      print("Problem Downloading File");
    }

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => InitialPage()));

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loading
            ? Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: progress,
                ),
              )
            : Text("Erro"),
      ),
    );
  }
}
