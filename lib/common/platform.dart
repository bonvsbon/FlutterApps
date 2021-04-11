import 'dart:io';

import 'package:path_provider/path_provider.dart';

class GetPlatForm {
  String isStorage = "";

  Future<String> checkPlatform() async {
    if (Platform.isAndroid) {
      return "222222222222";
    } else {
      _localPath.then((String value) {
        return value;
      });
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    // print('_localPath' + directory.path);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    // print("Path:_________________$path");
    return File(path);
  }
}
