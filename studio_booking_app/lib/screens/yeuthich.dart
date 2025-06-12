import 'package:flutter/material.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';

class YeuThichDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return YeuThichState();
  }
}

class YeuThichState extends State<YeuThichDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white, // Đặt màu nền trắng cho toàn màn hình
      body: SafeArea(
        child: SingleChildScrollView(
            child: Container(
              color: white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    child: Container(
                      color: white,
                      width: 150,
                      height: 180,
                      child: Stack(
                        children: [
                          Image.asset(
                            "lib/assets/images/anh.jpg",
                            fit: BoxFit.cover,
                            width: 150,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                              ),
                              child: Icon(Icons.filter, color: Colors.white, size: 16), // Biểu tượng máy ảnh
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: Text(
                                '400,000₫',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Nếu có nhiều mục yêu thích, bạn có thể thêm chúng vào đây bằng cách lặp.
                ],
              ),
            )
        ),
      ),
    );
  }
}
