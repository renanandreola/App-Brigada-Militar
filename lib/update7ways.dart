import 'dart:developer';
import 'dart:io';

import 'package:app_brigada_militar/initialPage.dart';
import 'package:archive/archive.dart';
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
    _downloadFiles();
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
          await unarchiveAndSave(saveFile, directory.path);

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

  unarchiveAndSave(var zippedFile, var directory_path) async {
    var bytes = zippedFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);

    for (var file in archive) {
      // inspect(file);
      var fileName = '$directory_path/${file.name}';

      if (file.isFile) {
        var outFile = File(fileName);
        print('File:: ' + outFile.path);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      } else {

      }
    }
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

    bool downloaded = await saveFile("https://docs.google.com/uc?export=download&id=1tKLgPXL3bqFNQQWA3B9SzdFs4Yw7tF2r&confirm=t&uuid=c46bf094-12b5-4b7e-b3db-07bedb37c555&at=AGu7sGrepsiC-By_ZP3NjEvMrI4w:1670112238898", "files.zip");

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
                  Text("Baixando... ${(progress * 100).toStringAsFixed(2)}%"),
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
          :  Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  Text("Verificando Arquivos, por favor aguarde..."),
                ]))
    );
  }
}
