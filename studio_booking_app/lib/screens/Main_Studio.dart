import 'package:flutter/material.dart';
import 'package:studio_booking_app/screens/service.dart';
import 'package:studio_booking_app/screens/userstudio_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Stu_Profile.dart';
import 'appointments.dart';
import 'list_post.dart';


class StudioPage extends StatefulWidget {
  final int studioId;
  StudioPage({required this.studioId});

  @override
  _StudioScreenState createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioPage> {
  final studioNameController = TextEditingController();
  final studioFollower = TextEditingController();
  String? studioAvatarUrl;

  final supabase = Supabase.instance.client;
  Map<String, int> statusCounts = {
    'Chờ xác nhận': 0,
    'Đã xác nhận': 0,
    'Hoàn thành': 0,
    'Đã hủy': 0,
  };

  Future<void> _loadStudioInfo(int studioID) async {
    try {
      if (studioID == null) {
        print("Studio ID không hợp lệ.");
        return;
      }

      final response = await supabase
          .from('StudioAccount')
          .select()
          .eq('studioID', studioID)
          .maybeSingle();

      if (response != null) {
        setState(() {
          studioNameController.text = response['studioName'] ?? '';
          studioFollower.text = (response['studioFollower'] ?? 0).toString();
          studioAvatarUrl = response['studioAvatar'];
          print("Đã tải dữ liệu. StuID: ${studioNameController.text}");
          print("Đã tải dữ liệu. Follower: ${studioFollower.text}");
        });
      } else {
        print("Không tìm thấy dữ liệu. StuID: $studioID");
      }
    } catch (e) {
      print("Lỗi khi tải dữ liệu: $e");
    }
  }

  Future<void> _fetchBookingCounts(int studioID) async {
    try {
      // Lấy danh sách spID liên quan đến studioID
      final serviceResponse = await supabase
          .from('ServicePackage')
          .select('spID')
          .eq('studioID', studioID);

      final spIDs = serviceResponse.map((e) => e['spID'] as int).toList();

      if (spIDs.isEmpty) {
        setState(() {
          statusCounts = {
            'Chờ xác nhận': 0,
            'Đã xác nhận': 0,
            'Hoàn thành': 0,
            'Đã hủy': 0,
          };
        });
        return;
      }

      // Tạo danh sách các trạng thái cần đếm
      final statuses = ['Chờ xác nhận', 'Đã xác nhận', 'Hoàn thành', 'Đã hủy'];
      final counts = {for (var status in statuses) status: 0};

      // Lặp qua từng spID và đếm cho từng trạng thái
      for (var spID in spIDs) {
        for (var status in statuses) {
          final response = await supabase
              .from('Booking')
              .select('*')
              .eq('spID', spID) // Lọc theo từng spID
              .eq('bookingStatus', status)
              .count();

          counts[status] = (counts[status] ?? 0) + (response.count ?? 0);
        }
      }

      setState(() {
        statusCounts = counts;
      });
    } catch (e) {
      print('Lỗi khi lấy số lượng đặt lịch: $e');
      setState(() {
        statusCounts = {
          'Chờ xác nhận': 0,
          'Đã xác nhận': 0,
          'Hoàn thành': 0,
          'Đã hủy': 0,
        };
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStudioInfo(widget.studioId);
    _fetchBookingCounts(widget.studioId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(59, 5, 16, 1.0),
      body: SingleChildScrollView( // Thay Expanded bằng SingleChildScrollView để tránh tràn
        child: Column(
          children: [
            StudioProfile(
              studioName: studioNameController.text,
              studioFollower: studioFollower.text,
              studioAvatarUrl: studioAvatarUrl,
              studioID: widget.studioId,
            ),
            const SizedBox(height: 20),
            AppointmentStatus(
              stuID: widget.studioId,
              statusCounts: statusCounts, // Truyền statusCounts vào AppointmentStatus
            ),
            const SizedBox(height: 20),
            const SizedBox(
              height: 2,
              child: ColoredBox(
                color: Color(0xFF3b0510),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: 250,
                    child: Text(
                      'QUẢN LÍ TRANG',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFf1f1f4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PageManagement(stuID: widget.studioId),
          ],
        ),
      ),
    );
  }
}

class StudioProfile extends StatelessWidget {
  final String studioName;
  final String studioFollower;
  final String? studioAvatarUrl;
  final int studioID;
  StudioProfile({
    required this.studioName,
    required this.studioFollower,
    required this.studioAvatarUrl,
    required this.studioID,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 5,
      child: Container(
        color: const Color.fromRGBO(59, 5, 16, 1.0),
        width: double.infinity,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context); // Quay lại màn hình trước
                  },
                  icon: const Icon(Icons.arrow_back_ios_outlined,
                      size: 25, color: Color(0xFFf4f4f1)),
                ),
                IconButton(
                  onPressed: () {
                    // Thêm logic cho thông báo
                  },
                  icon: const Icon(Icons.notifications_outlined,
                      size: 28, color: Color(0xFFf4f4f1)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              leading: CircleAvatar(
                backgroundImage: studioAvatarUrl != null
                    ? NetworkImage(studioAvatarUrl!)
                    : const AssetImage('assets/avatar.png') as ImageProvider,
                radius: 28,
              ),
              title: Text(
                studioName,
                style: const TextStyle(
                  color: Color(0xFFf4f4f1),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '$studioFollower người theo dõi',
                style: const TextStyle(
                  color: Color(0xFFf4f4f1),
                  fontSize: 15,
                ),
              ),
              trailing: TextButton(
                onPressed: () {
                  // Thêm logic xem trang
                },
                style: TextButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFf4f4f1), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: const Color(0xFFf1f1f4),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserStudioPage(studioID: studioID),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      'Xem trang',
                      style: TextStyle(
                        color: Color.fromRGBO(59, 5, 16, 1.0),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class AppointmentStatus extends StatefulWidget {
  final int stuID;
  final Map<String, int> statusCounts;

  AppointmentStatus({required this.stuID, required this.statusCounts});

  @override
  _AppointmentStatusState createState() => _AppointmentStatusState();
}

class _AppointmentStatusState extends State<AppointmentStatus> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: SizedBox(
                  width: 150,
                  child: Text(
                    'LỊCH HẸN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFf1f1f4),
                    ),
                  ),
                ),
              ),
              Container(
                width: 170,
                child: ListTile(
                  title: const Text(
                    'Xem tất cả',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFf1f1f4),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 20,
                    color: Color(0xFFf1f1f4),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Appointments(
                          initialTabIndex: 0,
                          stuID: widget.stuID,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            width: double.infinity,
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatusItem('Chờ xác nhận', widget.statusCounts['Chờ xác nhận'] ?? 0,1, widget.stuID,
              ),
              StatusItem('Đã xác nhận', widget.statusCounts['Đã xác nhận'] ?? 0, 2,widget.stuID,
              ),
              StatusItem( 'Hoàn thành',widget.statusCounts['Hoàn thành'] ?? 0, 3,widget.stuID,
              ),
              StatusItem( 'Đã hủy', widget.statusCounts['Đã hủy'] ?? 0, 4, widget.stuID,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusItem extends StatelessWidget {
  final String title;
  final int count;
  final int tabIndex;
  final int studioID;

  StatusItem(this.title, this.count, this.tabIndex, this.studioID);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 130,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Appointments(
                initialTabIndex: tabIndex,
                stuID: studioID,
              ),
            ),
          );
        },
        style: TextButton.styleFrom(
          side: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: const TextStyle(color: Color(0xFF3b0510), fontSize: 37),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF3A3737),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageManagement extends StatelessWidget {
  final int stuID;

  PageManagement({required this.stuID});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Column(
            children: [
              _buildListItem(context, "Bài viết", Icons.article, stuID),
              _buildListItem(context, "Dịch vụ", Icons.design_services, stuID),
              _buildListItem(context, "Tài khoản", Icons.account_circle, stuID),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String title, IconData icon, int stuID, [int? count]) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        leading: Icon(icon, color: const Color.fromRGBO(59, 5, 16, 1.0), size: 30),
        title: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        subtitle: count != null
            ? Text('$count mục', style: const TextStyle(color: Color.fromRGBO(59, 5, 16, 1.0), fontSize: 18))
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 25, color: Colors.grey),
        onTap: () {
          _navigateToScreen(context, title, stuID);
        },
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String title, int stuID) {
    final Map<String, Widget Function(BuildContext, int)> screens = {
      "Bài viết": (context, stuID) => PostListPage(studioID: stuID),
      "Dịch vụ": (context, stuID) => ServicesScreen(studioID: stuID),
      "Tài khoản": (context, stuID) => Stu_ProfileScreen(studioID: stuID),
    };

    if (screens.containsKey(title)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screens[title]!(context, stuID)),
      );
    }
  }
}
