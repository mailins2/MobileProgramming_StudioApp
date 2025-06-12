import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingDetail extends StatelessWidget {
  final Map<String, dynamic> booking; // Nhận thông tin booking từ màn hình trước

  BookingDetail({required this.booking});
  final supabase = Supabase.instance.client;
  Future<void> _updateBookingStatus(String newStatus, BuildContext context) async {
    try {
      await supabase
          .from('Booking')
          .update({'bookingStatus': newStatus})
          .eq('bookingID', booking['bookingID']);
      // Sau khi cập nhật, quay lại màn hình trước
      Navigator.pop(context); // Đóng dialog
      Navigator.pop(context); // Quay lại màn hình trước
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  void _showConfirmationDialog(String action, String newStatus, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: Text('Bạn có chắc muốn $action lịch hẹn này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog mà không làm gì
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                await _updateBookingStatus(newStatus, context);
              },
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chi tiết lịch hẹn",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFf4f4f1))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined, color:  Color(0xFFf4f4f1),size: 25,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF3b051a),
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04), // Điều chỉnh padding theo màn hình
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05), // Điều chỉnh padding bên trong
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.note_alt, color: Color.fromRGBO(59, 5, 16, 1.0), size: MediaQuery.of(context).size.width * 0.06),
                        Expanded(
                          child: Text(
                            "Ghi chú : ",
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04, color: Colors.grey[700]),
                          ),
                        ),
                        Divider(thickness: 1, color: Colors.grey[300]),
                        Expanded(
                            child: Center(
                              child: Text(
                                "${booking['bookingNotes'] ?? 'Không có ghi chú'}",
                                style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),
                              ),
                            )
                        ),
                      ],
                    ),
                    Divider(thickness: 1, color: Colors.grey[300]),

                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in, color: Color.fromRGBO(59, 5, 16, 1.0), size: MediaQuery.of(context).size.width * 0.06),
                        Expanded(
                          child: Text(
                            "Trạng thái: ${booking['bookingStatus']}",
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    Divider(thickness: 1, color: Colors.grey[300]),

                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.access_time, color: Color.fromRGBO(59, 5, 16, 1.0), size: MediaQuery.of(context).size.width * 0.06),
                        Expanded(
                          child: Text(
                            "Thời gian: ${booking['bookingTime']}",
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    Divider(thickness: 1, color: Colors.grey[300]),

                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.group, color: Color.fromRGBO(59, 5, 16, 1.0), size: MediaQuery.of(context).size.width * 0.06),
                        Expanded(
                          child: Text(
                            "Số người: ${booking['numberOfPeople'] ?? 'Không xác định'}",
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),

            ),

            // Chỉ hiển thị nút khi trạng thái là "Chưa xác nhận"
            if (booking['bookingStatus'] == 'Chưa xác nhận')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Thêm logic xác nhận
                          _showConfirmationDialog('xác nhận', 'Đã xác nhận', context);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (states) {
                              if (states.contains(MaterialState.pressed)) {
                                return const Color.fromRGBO(101, 19, 38, 0.6); // Màu khi nhấn
                              }
                              return const Color.fromRGBO(59, 5, 16, 1.0); // Màu mặc định
                            },
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Màu chữ
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.white, width: 2), // Viền
                            ),
                          ),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        child: const Text("Xác Nhận", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 10), // Khoảng cách giữa 2 nút
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Thêm logic hủy
                          _showConfirmationDialog('xác nhận', 'Đã xác nhận', context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFf1f1f4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color.fromRGBO(59, 5, 16, 1.0), width: 1),
                        ),
                        child: const Text("Hủy", style: TextStyle(color: Color.fromRGBO(59, 5, 16, 1.0), fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        )

      ),
    );
  }
}