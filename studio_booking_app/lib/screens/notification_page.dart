import 'package:flutter/material.dart';
import 'package:studio_booking_app/services/account_service.dart';
import 'package:studio_booking_app/constants/notification_function.dart';
import 'package:studio_booking_app/screens/thongbao.dart';
import 'package:studio_booking_app/screens/thongbao_artist.dart';


class ThongBaoPage extends StatefulWidget {
  final int currentUserId;

  ThongBaoPage({required this.currentUserId});

  @override

  State<ThongBaoPage> createState() => _ThongBaoPageState();
}

class _ThongBaoPageState extends State<ThongBaoPage> {
  late Future<bool> _isStudio;

  @override
  void initState() {
    super.initState();
    _isStudio = AccountService.isStudioAccount(widget.currentUserId);
    listenToRealtimeBooking(widget.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isStudio,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              body: Center(
                  child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Lỗi khi tải thông báo')));
        } else {
          return snapshot.data == true
              ? ThongBaoArtistDemo(currentUserId: widget.currentUserId)
              : ThongBaoDemo(currentUserId: widget.currentUserId);
        }
      },
    );
  }


}


