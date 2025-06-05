import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';
import 'package:studio_booking_app/constants/text-font.dart';
import 'package:studio_booking_app/widgets/Post.dart';


class Homepage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Home();
  }
}

class Home extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        title: Center(
          child: Text(
            'Booking Studio',
            style: TextStyle(
              fontFamily: logo_font,
              fontWeight: logo_fontweight,
              fontSize: 25,
              color: red,
            ),
          ),
        ),
      ),
      body: Container(
        color: white,
        child: Container(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Post(context,index,10);
            },
            itemCount: 10,
          ),
        ),
      ),
    );
  }
}
