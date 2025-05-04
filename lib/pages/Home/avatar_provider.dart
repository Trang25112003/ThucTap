import 'package:flutter/material.dart';

class AvatarProvider extends ChangeNotifier {
  String? _userAvatarUrl;

  String? get userAvatarUrl => _userAvatarUrl;

  void setUserAvatarUrl(String url) {
    _userAvatarUrl = url;
    notifyListeners();
  }

  void clearAvatar() {
    _userAvatarUrl = null;
    notifyListeners();
  }
}
