import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';
import 'package:studio_booking_app/screens/homepage.dart';
import 'package:studio_booking_app/screens/search.dart';

class Default extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return DefaultPage();
  }

}

class DefaultPage extends State<StatefulWidget>{
  Widget bodyState = Homepage();
  int selectedIndex =0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('BottomNavigationBar Demo'),
      //   backgroundColor: Colors.cyan,
      // ),
      body: bodyState,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index){
          if (index ==0){
            setState(() {
              bodyState=Homepage();
              selectedIndex=0;
            });
          }
          else if (index ==1){
            setState(() {
              bodyState = SearchPage();
              selectedIndex=1;
            });
          }
          else{
            setState(() {
              // bodyState =Test();
              selectedIndex=2;
            });
          }
        },
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
      ),
    );
  }

}