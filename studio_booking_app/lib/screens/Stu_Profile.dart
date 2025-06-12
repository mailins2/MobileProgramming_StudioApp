import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class Stu_ProfileScreen extends StatefulWidget {
  final int studioID;
  const Stu_ProfileScreen({Key? key, required this.studioID}) : super(key: key);

  @override
  Stu_ProfileScreenState createState() => Stu_ProfileScreenState();
}

class Stu_ProfileScreenState extends State<Stu_ProfileScreen> {
  bool isEditing = false;
  final TextEditingController studioAccountNameController = TextEditingController();
  final TextEditingController studioNameController = TextEditingController();
  final TextEditingController studioFollowerController = TextEditingController();
  final TextEditingController studioBookingController = TextEditingController();
  final TextEditingController studioRateController = TextEditingController();
  final TextEditingController studioBioController = TextEditingController();
  final TextEditingController studioAddressController = TextEditingController();
  String? studioAvatarUrl;
  File? _pickedImage;
  final picker = ImagePicker();
  bool isLoading = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadStudioInfo(widget.studioID);
  }

  Future<void> _loadStudioInfo(int studioID) async {
    try {
      final response = await supabase
          .from('StudioAccount')
          .select()
          .eq('studioID', studioID)
          .maybeSingle();

      if (response != null) {
        setState(() {
          studioAccountNameController.text = response['studioAccountName'] ?? '';
          studioNameController.text = response['studioName'] ?? '';
          studioFollowerController.text = (response['studioFollower'] ?? 0).toString();
          studioBookingController.text = (response['studioBooking'] ?? 0).toString();
          studioRateController.text = (response['studioRate'] ?? 0.0).toString();
          studioBioController.text = response['studioBio'] ?? '';
          studioAddressController.text = response['studioAddress'] ?? '';
          studioAvatarUrl = response['studioAvatar'];
          print("Đã tải dữ liệu cho Studio ID: $studioID");
        });
      } else {
        print("Không tìm thấy dữ liệu cho Studio ID: $studioID");
      }
    } catch (e) {
      print("Lỗi khi tải dữ liệu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _pickedImage = File(pickedFile.path);
      }
    });
  }

  Future<String> uploadStudioAvatar(String studioID) async {
    if (_pickedImage == null) {
      throw Exception("Không có ảnh nào được chọn!");
    }

    final folderPath = studioID;
    final fileBytes = await _pickedImage!.readAsBytes();
    final fileExt = p.extension(_pickedImage!.path);
    final fileName = 'avatar$fileExt'; // ví dụ: avatar.jpg
    final filePath = '$folderPath/$fileName';

    try {
      // Xóa ảnh cũ nếu tồn tại
      if (studioAvatarUrl != null) {
        final oldFilePath = studioAvatarUrl!.split('/').last;
        final oldFullPath = '$studioID/$oldFilePath';
        try {
          await supabase.storage.from('studio-avatar').remove([oldFullPath]);
          print("Đã xóa ảnh cũ: $oldFullPath");
        } catch (e) {
          print("Lỗi khi xóa ảnh cũ: $e");
          // Tiếp tục tải ảnh mới ngay cả khi xóa ảnh cũ thất bại
        }
      }

      // Tải ảnh mới lên
      await supabase.storage.from('studio-avatar').uploadBinary(
        filePath,
        fileBytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      // Lấy URL công khai
      final publicUrl = supabase.storage.from('studio-avatar').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception("Upload avatar thất bại: $e");
    }
  }

  Future<void> updateStudioAccount() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Kiểm tra studioAddress không rỗng (do ràng buộc NOT NULL)
      if (studioAddressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Địa chỉ không được để trống')),
        );
        return;
      }

      // Thu thập dữ liệu từ controllers
      final updatedData = {
        'studioAccountName': studioAccountNameController.text.isEmpty ? null : studioAccountNameController.text,
        'studioName': studioNameController.text.isEmpty ? null : studioNameController.text,
        'studioAddress': studioAddressController.text,
        'studioBio': studioBioController.text.isEmpty ? null : studioBioController.text,
      };

      // Tải ảnh lên nếu có
      if (_pickedImage != null) {
        final newAvatarUrl = await uploadStudioAvatar(widget.studioID.toString());
        updatedData['studioAvatar'] = newAvatarUrl;
      }

      // Gửi yêu cầu cập nhật tới Supabase
      await supabase
          .from('StudioAccount')
          .update(updatedData)
          .eq('studioID', widget.studioID);

      // Cập nhật studioAvatarUrl để hiển thị ảnh mới
      if (_pickedImage != null) {
        setState(() {
          studioAvatarUrl = updatedData['studioAvatar'];
          _pickedImage = null; // Xóa ảnh cục bộ sau khi tải lên
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Cập nhật thông tin Studio thành công!",
            style: TextStyle(fontSize: 16, color: Color(0xFFf4f4f1)),
          ),
        ),
      );
      await Future.delayed(Duration(seconds: 2)); // Đợi 2 giây
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: $e'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: Color(0xFFf4f4f1),
            size: 25,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit, color: Color(0xFFf1f1f4)),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
                if (!isEditing) {
                  updateStudioAccount(); // Lưu dữ liệu khi tắt chế độ chỉnh sửa
                }
              });
            },
          ),
        ],
        backgroundColor: Color(0xFF3b051a),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            GestureDetector(
              onTap: isEditing ? _pickImage : null,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 85,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : studioAvatarUrl != null
                        ? NetworkImage(studioAvatarUrl!)
                        : AssetImage('assets/avatar.png') as ImageProvider,
                  ),
                  if (isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.black, size: 30),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Column(
                children: [
                  buildTextField("Tên tài khoản", studioAccountNameController, 1, isEditing),
                  buildTextField("Tên hiển thị", studioNameController, 1, isEditing),
                  buildTextField("Địa chỉ", studioAddressController, 1, false),
                  buildTextField("Giới thiệu Studio", studioBioController, 3, isEditing),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, int minLines, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        style: TextStyle(fontSize: 20, color: Color(0xFF221516)),
        controller: controller,
        readOnly: !isEditing,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 20, color: Color(0xFF3b051a)),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Color.fromRGBO(225, 219, 215, 0.5), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Color.fromRGBO(225, 219, 215, 1.0), width: 1.0),
          ),
        ),
        minLines: minLines,
        maxLines: 3,
      ),
    );
  }
}