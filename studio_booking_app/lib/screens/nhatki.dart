import 'package:studio_booking_app/screens/lichhen.dart';
import 'package:studio_booking_app/screens/yeuthich.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';
class NhatKiDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NhatKiState();
  }
}

class NhatKiState extends State<NhatKiDemo> {
  int _selectedIndex = 2; // Index cho "Nhật ký" (tab Nhật ký trong BottomNavigationBar)
  List<bool> _isSelected = [true, false];
  bool _showAppointments = true; // Biến để chuyển đổi giữa Lịch hẹn (true) và Yêu thích (false)

  // Hàm được gọi khi một mục trong BottomNavigationBar được chạm
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        toolbarHeight: 120, // Tăng chiều cao của AppBar để chứa tiêu đề và nút chuyển đổi
        elevation: 0, // Xóa bóng đổ của AppBar
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Canh trái các thành phần trong Column
            children: [
              // Bộ chuyển đổi Lịch hẹn / Yêu thích (một button lớn)
              Center( // Dùng Center để căn giữa ToggleButtons
                child: ToggleButtons(
                  isSelected: _isSelected, // Trạng thái chọn của từng nút
                  onPressed: (int index) {
                    setState(() {
                      // Logic để chỉ một nút được chọn tại một thời điểm
                      for (int i = 0; i < _isSelected.length; i++) {
                        _isSelected[i] = (i == index); // Đặt true cho nút được nhấn, còn lại là false
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(20), // Bo góc cho toàn bộ button
                  borderColor: Colors.grey[300], // Màu viền khi không được chọn
                  selectedBorderColor: Colors.grey[300], // Màu viền khi được chọn
                  fillColor: Colors.grey[300], // Màu nền khi được chọn
                  color: Colors.grey[700], // Màu chữ khi không được chọn
                  selectedColor: Colors.black, // Màu chữ khi được chọn
                  // Danh sách các widget con (tức là các "nút" bên trong ToggleButtons)
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 2), // Kích thước nút Lịch hẹn
                      child: Text(
                        'Lịch hẹn',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 2), // Kích thước nút Yêu thích
                      child: Text(
                        'Yêu thích',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20), // Khoảng cách giữa nút chuyển đổi và tiêu đề
              // Tiêu đề "Lịch Hẹn" hoặc "Yêu Thích"
              Text(
                // Dựa vào trạng thái của _isSelected[0] để hiển thị tiêu đề
                _isSelected[0] ?  'Lịch Hẹn' : 'Yêu Thích',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      // Body của Scaffold sẽ hiển thị màn hình LichHenDemo hoặc YeuThichDemo
      // dựa trên giá trị của _showAppointments
      body: _isSelected[0] ? LichHenDemo() : YeuThichDemo(),

    );
  }
}