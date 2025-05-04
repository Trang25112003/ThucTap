import 'package:flutter/material.dart';

class UserInfoProvider extends ChangeNotifier {
  String _username = "User";

  String get username => _username;

  void setUsername(String name) {
    _username = name;
    notifyListeners();
  }
}
