import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static Future<void> setUser(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', uid);
  }

  static Future<String> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid') ?? '';
  }
}
