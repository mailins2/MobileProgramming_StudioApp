import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'detail_appointment.dart';
final supabase = Supabase.instance.client;
class Appointments extends StatefulWidget {
  final int initialTabIndex;
  final int stuID;

  Appointments({required this.initialTabIndex, required this.stuID});


  @override
  AppointmentsState createState() => AppointmentsState();
}

class AppointmentsState extends State<Appointments> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex, // Nhận tab ban đầu từ StatusItem
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Future<List<dynamic>> fetchBookings(String status) async {
    print("Fetching bookings for studioID: ${widget.stuID}");
    var query = Supabase.instance.client
        .from('Booking')
        .select('*, ServicePackage!inner(*)') // Kết hợp bảng ServicePackage
        .eq('ServicePackage.studioID', widget.stuID); // Lọc theo studioID

    if (status != 'Tất cả') {
      query = query.eq('bookingStatus', status); // Lọc theo trạng thái
    }

    return await query;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined, size: 25, color: Color(0xFFf1f1f4)),
        ),
        centerTitle: true,
        title: Text(
          'LỊCH HẸN',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFf1f1f4)),
        ),
        bottom: TabBar(
          indicatorColor: Color(0xFFe1dbd7),
          labelColor: Color(0xFFf1f1f4),
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 15),
          unselectedLabelColor: Color(0xFFf1f1f4),
          controller: _tabController,
          tabs: [
            Tab(text: "Tất cả"),
            Tab(text: "Chưa xác nhận"),
            Tab(text: "Đã xác nhận"),
            Tab(text: "Hoàn thành"),
            Tab(text: "Đã hủy"),
          ],
        ),
        backgroundColor: Color.fromRGBO(59, 5, 16, 1.0),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildBookingsList("Tất cả"),
          buildBookingsList("Chưa xác nhận"),
          buildBookingsList("Đã xác nhận"),
          buildBookingsList("Hoàn thành"),
          buildBookingsList("Đã hủy"),
        ],
      ),
    );
  }
  Widget buildBookingsList(String status) {
    return FutureBuilder(
      future: fetchBookings(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Lỗi tải dữ liệu"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Không có lịch hẹn nào"));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var booking = snapshot.data![index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Color(0xFFf1f1f4), // Đổi màu border theo ý muốn
                    width: 1, // Độ dày border
                  ),

                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Color.fromRGBO(59, 5, 16, 1.0),
                    child: Icon(Icons.calendar_today, color: Color(0xFFf1f1f4)),
                  ),
                  title: Text(
                    booking['bookingNotes'] ?? "Không có ghi chú",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Trạng thái: ${booking['bookingStatus']}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Color.fromRGBO(59, 5, 16, 1.0)),
                  onTap: () {
                    // Thêm hành động khi nhấn vào lịch hẹn, ví dụ mở chi tiết
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetail(booking: booking),
                      ),
                    );

                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}