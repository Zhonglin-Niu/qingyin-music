import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences? prefs;

  static init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static set(String key, dynamic value) {
    if (value.runtimeType == List<String>) {
      prefs?.setStringList(key, value);
    } else if (value.runtimeType == bool) {
      prefs?.setBool(key, value);
    } else if (value.runtimeType == String) {
      prefs?.setString(key, value);
    } else if (value.runtimeType == double) {
      prefs?.setDouble(key, value);
    } else if (value.runtimeType == int) {
      prefs?.setInt(key, value);
    }
  }

  static get(String key) {
    return prefs?.get(key);
  }

  static List<String>? getList(String key) {
    return prefs?.getStringList(key);
  }

  static remove(String key) {
    prefs?.remove(key);
  }

  static getAll() {
    var keys = prefs?.getKeys();
    Map<String, dynamic> dict = {};
    if (keys != null) {
      for (var key in keys) {
        dict.addAll({key: prefs?.get(key)});
      }
    }
    return dict;
  }
}
