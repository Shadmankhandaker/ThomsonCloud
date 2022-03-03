// ignore_for_file: file_names

import 'package:shared_preferences/shared_preferences.dart';

class PersistentUrl {
  static const _keyUrl = 'url';
  static late SharedPreferences _prefs;
  static Future initi() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ignore: non_constant_identifier_names
  static SetLocalUrl(String url) {
    _prefs.setString(_keyUrl, url);
  }

  // ignore: non_constant_identifier_names
  static String? GetLocalUrl() => _prefs.getString(_keyUrl);

  static RemoveLocalUrl() {
    _prefs.remove(_keyUrl);
  }
}
