import 'package:flutter/material.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';
import 'package:studio_booking_app/screens/homepage.dart';
import 'package:studio_booking_app/screens/search.dart';
import 'package:studio_booking_app/providers/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:studio_booking_app/screens/nhatki.dart';
import 'package:studio_booking_app/screens/notification_page.dart';
import 'package:studio_booking_app/screens/taikhoan_user_page.dart';
class Default extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DefaultPage();
  }
}

class DefaultPage extends State<Default> {
  Widget bodyState = Homepage();
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      body: bodyState,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;

            if (index == 0) {
              bodyState = Homepage();
            } else if (index == 1) {
              bodyState = SearchPage();
            } else if (index == 2) {
              bodyState = NhatKiDemo();
            } else if (index == 3) {
              if (user != null && user.id != null) {
                bodyState = ThongBaoPage(currentUserId: user.id);
              } else {
                // Có thể hiển thị thông báo, điều hướng đến đăng nhập, hoặc giữ nguyên giao diện hiện tại
                print("Người dùng chưa đăng nhập hoặc thiếu thông tin ID.");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bạn cần đăng nhập để xem thông báo.')),
                );
              }
            } else {
              if (user != null && user.id != null) {
                bodyState = AccountUserDemo(userID: user.id);
              } else {
                // Có thể hiển thị thông báo, điều hướng đến đăng nhập, hoặc giữ nguyên giao diện hiện tại
                print("Người dùng chưa đăng nhập hoặc thiếu thông tin ID.");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bạn cần đăng nhập để xem thông báo.')),
                );
              }
            }
          });
        },
        backgroundColor: white,
        selectedItemColor: red,
        unselectedItemColor: red,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Nhật ký'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: 'Tài khoản'),
        ],
      ),
    );
  }
}
