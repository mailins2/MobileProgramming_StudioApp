import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';

Widget BottomNavigation(int index){
  return BottomNavigationBar(
    backgroundColor: white,
    // elevation: 0.0,
    selectedItemColor: red,
    unselectedItemColor: red,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    type: BottomNavigationBarType.fixed,
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chủ'
      ),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm '),
      BottomNavigationBarItem(
        icon: Icon(Icons.event_note),
        label: 'Nhật ký ',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.notifications_outlined),
        label: 'Thông báo ',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_circle_outlined),
        label: 'Tài khoản ',
      ),
    ],
  );
}