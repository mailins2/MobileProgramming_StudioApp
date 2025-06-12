import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studio_booking_app/screens/change_password.dart';
import 'package:studio_booking_app/screens/signIn.dart';

import 'Check_Studio.dart';
class AccountUserDemo extends StatefulWidget {
  final int userID;
  const AccountUserDemo({Key? key, required this.userID}) : super(key: key);

  @override
  State<AccountUserDemo> createState() => AccountUserState();
}

class AccountUserState extends State<AccountUserDemo> {
  final supabase = Supabase.instance.client;
  String hoTen = '';
  String email = '';
  String soDienThoai = '';
  String diaChi = '';
  String avatarUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final res = await supabase
          .from('UserAcoount')
          .select()
          .eq('userId', widget.userID)
          .maybeSingle();

      if (res == null) {
        setState(() => isLoading = false);
        return;
      }

      setState(() {
        hoTen = res['userFullName'] ?? '';
        email = res['userEmail'] ?? '';
        soDienThoai = res['userPhoneNumber'] ?? '';
        diaChi = res['userAddress'] ?? '';
        avatarUrl = (res['userAvatar'] ?? '').replaceAll(RegExp(r'\s+'), '').trim();
        isLoading = false;
        print("Kết quả từ Supabase: $res");
      });
    } catch (e) {
      print("Lỗi khi lấy dữ liệu người dùng: $e");
      setState(() => isLoading = false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF4F4F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Bạn muốn đăng xuất tài khoản?', style: TextStyle(fontSize: 18)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ', style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('lastPhone', soDienThoai);
              await Future.delayed(const Duration(milliseconds: 600));
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) =>  SignIn()),
                    (route) => false,
              );
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: const Color(0xFF3B0510)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 30),
                  _buildPasswordCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(25.0),
        child: ElevatedButton(
          onPressed: _showLogoutDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B0510),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Đăng xuất",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      color: const Color(0xFF3B0510),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF4F4F1),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckUserStudioPage(userID: widget.userID),
                      ),
                    );
                  },
                  child: Row(
                    children: const [
                      Text('Đăng ký Studio', style: TextStyle(color: Colors.black, fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                    ],
                  ),
                  ),
                ),

            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: avatarUrl.isNotEmpty && avatarUrl.startsWith('http')
                      ? Image.network(
                    avatarUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/anh1.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                      : Image.asset(
                    'assets/images/anh1.jpg',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                hoTen.isNotEmpty ? hoTen : 'Người dùng',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: const Color(0xFFF4F4F1),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardTitle("THÔNG TIN CÁ NHÂN"),
            _buildProfileRow("Họ tên", hoTen),
            _buildProfileRow("Điện thoại", soDienThoai),
            _buildProfileRow("Email", email),
            _buildProfileRow("Địa chỉ", diaChi),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Card(
      color: const Color(0xFFF4F4F1),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangePasswordPage(userId: widget.userID),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shadowColor: Colors.transparent,
            elevation: 0,
            alignment: Alignment.centerLeft,
            backgroundColor: const Color(0xFFF4F4F1),
          ).copyWith(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MẬT KHẨU",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              Icon(Icons.edit_outlined, color: Colors.grey[700]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTitle(String title) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        elevation: 0,
        alignment: Alignment.centerLeft,
        backgroundColor: const Color(0xFFF4F4F1),
      ).copyWith(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          Icon(Icons.edit_outlined, color: Colors.grey[700]),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
