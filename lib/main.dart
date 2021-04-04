import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:path_provider_ex/path_provider_ex.dart';
import 'dart:async';
import 'api/main_api.dart';
import 'mainCall.dart' as mainCall;
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() {
  runApp(new PreLogin());
}

class PreLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PreLoginPage(
        title: 'Flutter Demo Home Page',
        description: 'You have pushed the button this many times:',
        image: 'assets/images/logo.png',
      ),
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PreLoginPage extends StatefulWidget {
  PreLoginPage({
    Key key,
    this.title,
    this.description,
    this.image,
  }) : super(key: key);
  final String title;
  final String description;
  final String image;

  @override
  _PreLoginState createState() => _PreLoginState();
}

class _PreLoginState extends State<PreLoginPage> with WidgetsBindingObserver {
  int _welcomeText = 0;
  ApiConnection api = new ApiConnection();
  TextEditingController pUsername = TextEditingController();
  TextEditingController pPassword = TextEditingController();
  String rootPath = "";
  bool isShown;
  @override
  void initState() {
    // request();
    rootPath = '/storage/emulated/0/Call';
    checkStateLogin();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> request() async {
    isShown = await Permission.contacts.shouldShowRequestRationale;
    var status = await Permission.camera.status;
    if (status.isUndetermined) {
      // We didn't ask for permission yet.
    }

    // You can can also directly ask the permission about its status.
    if (await Permission.location.isRestricted) {}
    if (await Permission.contacts.request().isGranted) {}
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
    ].request();

    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      // Use location.
    }

    if (await Permission.speech.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _callPass() {
    setState(() {
      _welcomeText++;
    });
  }

  Future<void> checkStateLogin() async {
    final myDir = Directory(rootPath);
    final authFile = getFilepattern();
    authFile.exists().then((bool hasFile) {
      String textRead = authFile.readAsStringSync();
      bool isTrue = checkAuthFile(textRead);
      if (isTrue) {
        print('Text in File is : $textRead');
        Map<String, dynamic> details = jsonDecode(textRead);
        print('Text in File is : ${details['Username']}');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => mainCall.MyApp(
                      currentName: details['Username'],
                    )));
      } else {
        authFile.delete();
      }
    });
  }

  bool checkAuthFile(String textRead) {
    bool result = true;
    switch (textRead) {
      case "404":
        result = false;
        break;
      case "500":
        result = false;
        break;
      case "401":
        result = false;
        break;
    }

    return result;
  }

  File getFilepattern() {
    return File("$rootPath/_authFile.txt");
  }

  Future<void> callLogin() async {
    EasyLoading.show(status: 'Please Wait...');
    Map<String, dynamic> params = {
      "username": pUsername.text,
      "password": pPassword.text
    };
    print(params);
    api.postMethodWithParam("Authorize", params).then((String result) {
      print(result);
      final f = getFilepattern();

      f.writeAsStringSync(result);

      bool checkAuth = checkAuthFile(result);
      print(checkAuth);
      if (checkAuth) {
        EasyLoading.showSuccess('Login Successfully!');
        Map<String, dynamic> details = jsonDecode(result);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => mainCall.MyApp(
                      currentName: details['Username'],
                    )));
      }

      // showDialog<void>(
      //     context: context,
      //     barrierDismissible: false,
      //     builder: (BuildContext context) {
      //       return AlertDialog(
      //         title: Text("Login Status"),
      //         content: SingleChildScrollView(
      //           child: ListBody(
      //             children: <Widget>[
      //               Text('TEST'),
      //             ],
      //           ),
      //         ),
      //         actions: <Widget>[
      //           TextButton(
      //               child: Text("OK"),
      //               onPressed: () {
      //                 Navigator.of(context).pop();
      //               })
      //         ],
      //       );
      //     });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 50, 10, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Image.asset(widget.image, fit: BoxFit.fill),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: pUsername,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Username",
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: pPassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Password",
                  ),
                  obscureText: true,
                  autofocus: false,
                ),
              ),
              // Container(
              //   child: Text('$_welcomeText'),
              // ),
              Container(
                  child: RaisedButton(
                child: Text(
                  "Sign In",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
                onPressed: callLogin,
              )),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _callPass,
      //   child: Icon(Icons.refresh),
      // ),
    );
  }
}
