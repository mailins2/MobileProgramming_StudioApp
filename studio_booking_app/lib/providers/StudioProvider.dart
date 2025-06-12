import 'package:flutter/material.dart';

class StudioProvider extends ChangeNotifier {
  int? _studioID;

  int? get studioID => _studioID;

  void setStudioID(int id) {
    _studioID = id;
    notifyListeners();
  }

  void clearStudioID() {
    _studioID = null;
    notifyListeners();
  }
}