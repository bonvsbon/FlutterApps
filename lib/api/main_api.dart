import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiConnection {
  Uri _request;
  // String _targetUrl = "synergy.nextcapital.co.th";
  // String _targetPath = "/webtest/servicehirepurchase/api/";
  String _targetUrl = "synergy.nextcapital.co.th";
  String _targetPath = "/webtest/APICore/api/";
  http.Response _response;
  Map<String, String> userHeader = {
    'content-type': 'application/json',
    'Accept': '*/*'
  };

  Future<String> getMethod(String module) async {
    _request = Uri.https(_targetUrl, _targetPath + module);
    _response = await http.get(_request);
    if (_response.statusCode == 200) {
      return _response.body;
    } else {
      // Api Error Status Code
      return "${_response.statusCode}";
    }
  }

  Future<String> getMethodWithParam(
      String module, Map<String, dynamic> params) async {
    _request = Uri.https(_targetUrl, _targetPath + module, params);
    _response = await http.get(_request);
    if (_response.statusCode == 200) {
      return _response.body;
    } else {
      // Api Error Status Code
      return "${_response.statusCode}";
    }
  }

  Future<String> postMethodWithParam(String module, Map params) async {
    _request = Uri.https(_targetUrl, _targetPath + module);
    _response = await http.post(_request,
        body: jsonEncode(params), headers: userHeader);
    if (_response.statusCode == 200) {
      return _response.body;
    } else {
      // Api Error Status Code
      return "${_response.statusCode}";
    }
  }

  Future<int> postMethodWithFile(
      String module, File file, String username) async {
    Map<String, String> param = {"username": username};
    _request = Uri.https(_targetUrl, _targetPath + module, param);
    var request = http.MultipartRequest('POST', _request);
    request.files.add(await http.MultipartFile.fromPath('files', file.path));
    http.StreamedResponse res = await request.send();
    print(request);
    return res.statusCode;
  }
}
