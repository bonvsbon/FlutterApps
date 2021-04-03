import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_state/flutter_phone_state.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:mobile_number/sim_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'api/main_api.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key key, this.currentName}) : super(key: key);
  final String currentName;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Welcome $currentName',
        description: 'You have pushed the button this many times:',
        image: 'assets/images/logo.png',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    this.title,
    this.description,
    this.image,
  }) : super(key: key);
  final String title;
  final String description;
  final String image;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  int _counter = 0;
  String _platformImei = 'Unknown';
  String uniqueId = "Unknown";
  String identifier;
  String _baseFolder;
  String _responseJson = "";
  String _serial = "";
  File singleFile;
  bool isShown = false;
  bool _stateCallOut = false;
  List<Widget> textWidgets = [];
  List<Widget> resultPath = [];
  List<Widget> resultListView = [];
  TextEditingController pUsername = new TextEditingController();
  TextEditingController pPassword = new TextEditingController();
  TextEditingController ptelno = new TextEditingController();
  ApiConnection _connection = new ApiConnection();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  String _mobileNumber = '';
  List<SimCard> _simCard = <SimCard>[];
  String rootPath;
  var files;
  @override
  void initState() {
    rootPath = "/storage/emulated/0/Call";
    super.initState();
    getDevice();
    _getId();
    _controlListView();
    //callAPI();

    WidgetsBinding.instance.addObserver(this);
  }

  void callAPI() async {
    Map _data = {"AgreementNo": "403180400062", "Id": "3770600021449"};
    Map data = {
      "_token": "__________",
      "_data": _data,
      "_sendfrom": "______ME"
    };

    _connection
        .postMethodWithParam("Customer/index", data)
        .then((String result) {
      setState(() {
        _responseJson = result;
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    String mobileNumber = '';
    // Platform messages may fail, so we use a try/catch PlatformException.

    mobileNumber = await MobileNumber.mobileNumber;
    _simCard = await MobileNumber.getSimCards;

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _mobileNumber = mobileNumber;
    });
  }

  Future<List<SimCard>> _getSim() async {
    final List<SimCard> simCards = await MobileNumber.getSimCards;
    return simCards;
  }

  Future<void> _getId() async {
    String result;
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      result = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      result = androidDeviceInfo.androidId; // unique ID on Android
    }
    setState(() {
      uniqueId = result;
    });
  }

  Future<void> getDevice() async {
    String imei =
        await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
    List<String> multiImei =
        await ImeiPlugin.getImeiMulti(); //for double-triple SIM phones
    String uuid = await ImeiPlugin.getId();

    setState(() {
      _platformImei = imei;
      // uniqueId = uuid;
    });
  }

  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  // // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   String platformImei;
  //   String idunique;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     platformImei =
  //         await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
  //     List<String> multiImei = await ImeiPlugin.getImeiMulti();
  //     print(multiImei);
  //     idunique = await ImeiPlugin.getId();
  //   } on PlatformException {
  //     platformImei = 'Failed to get platform version.';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _platformImei = platformImei;
  //     uniqueId = idunique;
  //   });
  // }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    print('_localPath' + directory.path);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print("Path:_________________$path");
    return File(path);
  }

  void _emptyListView() {
    resultListView.add(new ListTile(
      subtitle: Text('../Back to'),
      onTap: () {
        setState(() {
          _baseFolder = '/storage/emulated/0/Call';
        });
        _controlListView();
      },
      onLongPress: () {},
    ));
  }

  Future<Directory> _controlListView() async {
    resultListView = [];
    final myDir = Directory(rootPath);
    int counter = 1;
    bool x = await myDir.exists();
    _emptyListView();
    if (!x) {
      return myDir;
    }

    List<FileSystemEntity> files = myDir.listSync();
    for (FileSystemEntity file in files) {
      FileStat f = file.statSync();
      String fileName = path.basename(file.path);
      int statusCode;
      if (fileName.contains(".txt")) {
        continue;
      }
      resultListView.add(new ListTile(
        title: Text('ไฟล์เสียงที่ $counter'),
        subtitle: Text('ชื่่อ $fileName'),
        leading: Icon(Icons.add_ic_call_rounded),
        onTap: () {
          setState(() {
            _baseFolder = fileName;
          });
          _controlListView();
        },
        onLongPress: () {},
      ));
      counter++;
      // await _connection.postMethodWithFile('File', file).then((int code) {
      //   statusCode = code;
      //   print("Status Code is : ${statusCode}");
      // });
      // file.delete();
    }
  }

  Future<Directory> mainz() async {
    final myDir = Directory('/storage/0F1D-2619/Call');
    List<FileSystemEntity> files = myDir.listSync();

    for (FileSystemEntity f in files) {
      FileStat f1 = f.statSync();
      resultPath.add(new Image.file(new File(f.absolute.path)));
    }

    return myDir;
  }

  void _pressedCall() {
    // showDialog<void>(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: Text("Information Telephone"),
    //         content: SingleChildScrollView(
    //           child: ListBody(
    //             children: <Widget>[
    //               Text("Value of Mobile Device"),
    //               Text("Imei is : $_platformImei"),
    //               Text("UniqueId is : $uniqueId")
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
    launch("tel://" + ptelno.text);
    // setState(() {
    //   FlutterPhoneState.startPhoneCall(ptelno.text);
    //   _stateCallOut = FlutterPhoneState.startPhoneCall(ptelno.text).isComplete;
    // });
  }

  void _onStateCallOut() {
    _stateCallOut = FlutterPhoneState.startPhoneCall(ptelno.text).isComplete;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        print('State is : pause');
        break;
      case AppLifecycleState.resumed:
        print('State is : resume');
        // GetFileforUpload

        // _onStateCallOut();
        break;
      case AppLifecycleState.inactive:
        print('State is : inactive');
        break;
      case AppLifecycleState.detached:
        print('State is : detached');
        break;
    }
  }

  Widget fillCards() {
    List<Widget> widgets = _simCard
        .map((SimCard sim) => Text(
            'Sim Card Number: (${sim.countryPhonePrefix}) - ${sim.number}\nCarrier Name: ${sim.carrierName}\nCountry Iso: ${sim.countryIso}\nDisplay Name: ${sim.displayName}\nSim Slot Index: ${sim.slotIndex}\n\n'))
        .toList();
    return Column(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
          padding: EdgeInsets.all(10),
          child: Container(
            child: ListView(children: [
              Text(_responseJson),
              TextField(
                controller: ptelno,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Telephone Number",
                ),
              ),
              ...resultListView,
              RaisedButton.icon(
                label: Text('Submit Recording File...',
                    style: TextStyle(color: Colors.white)),
                icon: Icon(Icons.save_alt, size: 18, color: Colors.white),
                color: Colors.blue,
                onPressed: _pressedCall,
              ),
              ...textWidgets,
              Text('Running on: $_mobileNumber\n'),
              fillCards(),
            ]),
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
          setState(() {
            textWidgets.add(Text('androidId: ${androidInfo.androidId}'));
            textWidgets.add(Text('board: ${androidInfo.board}'));
            textWidgets.add(Text('bootloader: ${androidInfo.bootloader}'));
            textWidgets.add(Text('brand: ${androidInfo.brand}'));
            textWidgets.add(Text('device: ${androidInfo.device}'));
            textWidgets.add(Text('display: ${androidInfo.display}'));
            textWidgets.add(Text('fingerprint: ${androidInfo.fingerprint}'));
            textWidgets.add(Text('hardware: ${androidInfo.hardware}'));
            textWidgets.add(Text('hashCode: ${androidInfo.hashCode}'));
            textWidgets.add(Text('host: ${androidInfo.host}'));
            textWidgets.add(Text('id: ${androidInfo.id}'));
            textWidgets
                .add(Text('isPhysicalDevice: ${androidInfo.isPhysicalDevice}'));
            textWidgets.add(Text('manufacturer: ${androidInfo.manufacturer}'));
            textWidgets.add(Text('model: ${androidInfo.model}'));
            textWidgets.add(Text('product: ${androidInfo.product}'));
            textWidgets.add(Text('tags: ${androidInfo.tags}'));
          });
        },
        tooltip: 'Increment',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
