
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Notification{
  late String _NotiType ;
  late String _NotiTitle ;
  late String _NotiContent ;
  late DateTime _CreateDate ;



  String get NotiType => _NotiType;

  set NotiType(String value) {
    _NotiType = value;
  }

  String get NotiTitle => _NotiTitle;

  set NotiTitle(String value) {
    _NotiTitle = value;
  }

  DateTime get CreateDate => _CreateDate;

  set CreateDate(DateTime value) {
    _CreateDate = value;
  }

  String get NotiContent => _NotiContent;

  set NotiContent(String value) {
    _NotiContent = value;
  }


  Notification.name( this._NotiType, this._NotiTitle,
      this._NotiContent, this._CreateDate);

  Notification(){

    _NotiType = '';
    _NotiTitle = '';
     _NotiContent = '';
     _CreateDate = DateTime.now();

  }

}