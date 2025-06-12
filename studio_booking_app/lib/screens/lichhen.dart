import 'package:studio_booking_app/constants/colorpalette.dart';
import 'package:flutter/material.dart';

class LichHenDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LichHenState();
  }

}
class LichHenState extends State<LichHenDemo> {
  @override
  Widget build(BuildContext context) {
    return Center(
          child: SafeArea(
            child: Container(
              color: white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    child: Text("Trống",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.grey,

                      ),

                    ),
                  ),
                  Align(
                    child: Text("Hiện tại chưa có lịch hẹn nào.",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );

  }

}