import 'dart:io';
import 'package:http/io_client.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiConnection {
  Uri _request;
  // String _targetUrl = "192.168.4.126:5001";
  // String _targetPath = "/api/";
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
    // bool trustSelfSigned = true;
    // HttpClient httpClient = new HttpClient()
    //   ..badCertificateCallback =
    //       ((X509Certificate cert, String host, int port) => trustSelfSigned);
    // IOClient ioClient = new IOClient(httpClient);

    Map<String, String> param = {"username": username};
    _request = Uri.https(_targetUrl, _targetPath + module, param);
    var request = http.MultipartRequest('POST', _request);
    request.files.add(await http.MultipartFile.fromPath('files', file.path));
    http.StreamedResponse res = await request.send();
    // await ioClient.send(request).then((http.StreamedResponse response) {
    //   return response.statusCode;
    // });
    return res.statusCode;
  }
}
