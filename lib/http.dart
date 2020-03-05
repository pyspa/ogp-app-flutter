import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

typedef PostCallback = Future<String> Function();

class PostModel with ChangeNotifier {
  static const postUrl = "https://ogp.app/api/image";
  var _words = "";
  get words => _words;

  void setInput(String input) {
    this._words = input;
    debugPrint("input = $_words");
    notifyListeners();
  }

  void clear() {
    _words = "";
  }

  Future<String> post() async {
    debugPrint("POST $_words");

    var headers = {'content-type': 'application/json'};
    var body = json.encode({'words': _words});
    var resp = await http.post(postUrl, headers: headers, body: body);
    clear();
    if (resp.statusCode == 200) {
      var res = json.decode(resp.body);
      var id = res["id"];
      return "https://ogp.app/p/$id";
    } else {
      var txt = resp.body;
      throw Exception('Failed ' + txt);
    }
  }
}
