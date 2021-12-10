
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setPrefsValue(String variable, String setValue) async {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  prefs.setString(variable, setValue);
}

Future<String> getPrefsValue(String variable) async {
  String result = "";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  if(prefs.containsKey(variable)){
    result = prefs.getString(variable) ?? "";
  }
  return result;
}

Future<void> clearPrefs() async {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  await prefs.clear();
}

Future<void> removePrefsKey(String variable) async {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  if(prefs.containsKey(variable)){
    prefs.remove(variable);
  }
}
