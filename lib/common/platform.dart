import 'dart:io';

import 'package:path_provider/path_provider.dart';

class GetPlatForm {
  String isStorage = "/storage/emulated/0/Call";

  Future<String> checkPlatform() async {
    String val = isStorage;
    if (Platform.isIOS) {
      await _localPath.then((String value) {
        val = value;
      });
    }
    return val;
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
