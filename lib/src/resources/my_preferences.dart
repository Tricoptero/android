import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class MyPreferences  {
  SharedPreferences pref;



  Future<bool> init() async {
    pref = await SharedPreferences.getInstance();

    return true;
  }

  void setUsuario(String email, String password) {

    pref.setString('email', email);
    pref.setString('password', password);
  }

  void removeUsuario() {
    pref.remove('email');
    pref.remove('password');
  }

  Set<String>  keys() {
    return pref.getKeys();
  }

  String getEmail() => pref.get("email");
  String getPassword() => pref.get("password");
}