import 'package:flutter/material.dart';
import 'package:studio_booking_app/models/userModel.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
