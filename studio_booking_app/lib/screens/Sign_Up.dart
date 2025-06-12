import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/StudioProvider.dart';
import '../widgets/Post.dart';
import 'Main_Studio.dart';

class RegisterStuPage extends StatefulWidget {
  final int userID;
  RegisterStuPage({required this.userID});
  @override
  RegisterStuPageState createState() => RegisterStuPageState();
}

class RegisterStuPageState extends State<RegisterStuPage> {
  File? _pickedImage;
  String? avatarUrl;

  final picker = ImagePicker();
  final studioName = TextEditingController();
  final studioBio = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController(); // Optional, chỉ để hiển thị hoặc tạo mới
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
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
      await Supabase.instance.client.storage.from('studio-avatar').uploadBinary(
        filePath,
        fileBytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final publicUrl = Supabase.instance.client.storage.from('studio-avatar').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception("Upload avatar thất bại: $e");
    }
  }

  Future<void> _loadUserInfo(int? userId) async {

    if (userId == null) return;

    final response = await supabase
        .from('UserAcoount')
        .select()
        .eq('userId', userId)
        .maybeSingle();

    if (response != null) {
      setState(() {
        nameController.text = response['userFullName'] ?? '';
        phoneController.text = response['userPhoneNumber'] ?? '';

        emailController.text = response['userEmail'] ?? '';
        avatarUrl = response['userAvatar'];
      });
    }
  }

  List<dynamic> provincesData = [];
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;
  final _addressController = TextEditingController();
  Future<void> loadProvinces() async {
    final jsonStr = await rootBundle.loadString('lib/assets/data/data.json');
    final List<dynamic> jsonData = json.decode(jsonStr);
    setState(() {
      provincesData = jsonData;
    });
  }
  int _compareAlphaNumeric(String a, String b) {
    final regex = RegExp(r'(\d+)|(\D+)');
    final aMatches = regex.allMatches(a);
    final bMatches = regex.allMatches(b);

    final aList = aMatches.map((m) => m.group(0)!).toList();
    final bList = bMatches.map((m) => m.group(0)!).toList();

    for (int i = 0; i < aList.length && i < bList.length; i++) {
      final aPart = aList[i];
      final bPart = bList[i];

      final aNum = int.tryParse(aPart);
      final bNum = int.tryParse(bPart);

      if (aNum != null && bNum != null) {
        if (aNum != bNum) return aNum.compareTo(bNum);
      } else {
        final cmp = aPart.compareTo(bPart);
        if (cmp != 0) return cmp;
      }
    }

    return aList.length.compareTo(bList.length);
  }

  List<String> getProvinceNames() {
    final names =
    provincesData.map<String>((item) => item['Name'] as String).toList();
    names.sort(_compareAlphaNumeric);
    return names;
  }

  List<String> getDistrictNames() {
    if (selectedProvince == null) return [];
    final province = provincesData.firstWhere(
          (p) => p['Name'] == selectedProvince,
      orElse: () => null,
    );
    if (province == null) return [];
    final districts = province['Districts'] as List<dynamic>;
    final names = districts.map<String>((d) => d['Name'] as String).toList();
    names.sort(_compareAlphaNumeric);
    return names;
  }

  List<String> getWardNames() {
    if (selectedProvince == null || selectedDistrict == null) return [];
    final province = provincesData.firstWhere(
          (p) => p['Name'] == selectedProvince,
      orElse: () => null,
    );
    if (province == null) return [];
    final districts = province['Districts'] as List<dynamic>;
    final district = districts.firstWhere(
          (d) => d['Name'] == selectedDistrict,
      orElse: () => null,
    );
    if (district == null) return [];
    final wards = district['Wards'] as List<dynamic>;
    final names = wards.map<String>((w) => w['Name'] as String).toList();
    names.sort(_compareAlphaNumeric);
    return names;
  }
  void parseAddress(String address) {
    final parts = address.split(',');
    if (parts.length >= 4) {
      _addressController.text = parts[0].trim();
      selectedWard = parts[1].trim();
      selectedDistrict = parts[2].trim();
      selectedProvince = parts[3].trim();
    }
  }

// Hàm tạo Studio mới
//   Future<void> createStudioAccount(BuildContext context, int studioOwnerID) async {
//     String studioAccountName = nameController.text.trim(); // "Tên hiển thị"
//     String studioNameValue = studioName.text.trim();         // "Tên Studio"
//
//     parseAddress(_addressController.text);
//
//
//     String fullAddress = _addressController.text;
//     if (selectedWard != null) {
//       fullAddress += ', ${selectedWard!}';
//     }
//     if (selectedDistrict != null) {
//       fullAddress += ', ${selectedDistrict!}';
//     }
//     if (selectedProvince != null) {
//       fullAddress += ', ${selectedProvince!}';
//     }
//
//     String email = emailController.text.trim();
//     String bio = studioBio.text.trim();
//
//     try {
//
//       final response = await supabase.from('StudioAccount').insert({
//         'studioOwnerID': studioOwnerID,
//         'studioAccountName': studioAccountName,
//         'studioName': studioNameValue,
//         'studioAddress': fullAddress,
//         'studioBio': bio,
//         'studioAvatar': null, // sẽ cập nhật sau khi upload avatar
//       }).select('studioID').single();
//
//       final String studioID = response['studioID'].toString();
//       String? finalAvatarUrl;
//       if (_pickedImage != null) {
//         // Nếu người dùng chọn ảnh qua ImagePicker, upload ảnh đó
//         finalAvatarUrl = await uploadStudioAvatar(studioID);
//       } else if (avatarUrl != null) {
//         finalAvatarUrl = avatarUrl;
//       } else {
//         finalAvatarUrl = null;
//       }
//
//       if (finalAvatarUrl != null) {
//         await supabase.from('StudioAccount').update({
//           'studioAvatar': finalAvatarUrl,
//         }).eq('studioID', studioID);
//       }
//
//       Provider.of<StudioProvider>(context, listen: false)
//           .setStudioID(int.parse(studioID));
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Tạo Studio thành công!"),
//           backgroundColor: Colors.green,
//         ),
//       );
//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => StudioPage(studioId: int.parse(studioID),)),
//           );
//         }
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Lỗi khi tạo Studio: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

  Future<void> createStudioAccount(BuildContext context, int studioOwnerID) async {
    String studioAccountName = nameController.text.trim(); // Tên hiển thị
    String studioNameValue = studioName.text.trim();       // Tên studio
    String email = emailController.text.trim();
    String bio = studioBio.text.trim();
    parseAddress(_addressController.text);

    // Xây dựng địa chỉ đầy đủ
    String fullAddress = _addressController.text.trim();
    if (selectedWard != null) fullAddress += ', ${selectedWard!}';
    if (selectedDistrict != null) fullAddress += ', ${selectedDistrict!}';
    if (selectedProvince != null) fullAddress += ', ${selectedProvince!}';

    // Kiểm tra dữ liệu bắt buộc
    if (studioAccountName.isEmpty ||
        studioNameValue.isEmpty ||
        email.isEmpty ||
        _addressController.text.trim().isEmpty ||
        selectedWard == null ||
        selectedDistrict == null ||
        selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Vui lòng điền đầy đủ thông tin bắt buộc."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final response = await supabase.from('StudioAccount').insert({
        'studioOwnerID': studioOwnerID,
        'studioAccountName': studioAccountName,
        'studioName': studioNameValue,
        'studioAddress': fullAddress,
        'studioBio': bio.isNotEmpty ? bio : null,  // Mô tả có thể để trống
        'studioAvatar': null,
      }).select('studioID').single();

      final String studioID = response['studioID'].toString();
      String? finalAvatarUrl;

      if (_pickedImage != null) {
        finalAvatarUrl = await uploadStudioAvatar(studioID);
      } else if (avatarUrl != null) {
        finalAvatarUrl = avatarUrl;
      }

      if (finalAvatarUrl != null) {
        await supabase.from('StudioAccount').update({
          'studioAvatar': finalAvatarUrl,
        }).eq('studioID', studioID);
      }

      Provider.of<StudioProvider>(context, listen: false)
          .setStudioID(int.parse(studioID));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tạo Studio thành công!"),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => StudioPage(studioId: int.parse(studioID))),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tạo Studio: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _loadUserInfo(widget.userID);
    loadProvinces();
  }


  Widget build(BuildContext context) {
    final provinceNames = getProvinceNames();
    final districtNames = getDistrictNames();
    final wardNames = getWardNames();
    return Scaffold(
        appBar: AppBar(
         title: Text("Thông tin đăng kí studio", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xFFf1f1f4)),),
         centerTitle: true,
         leading: IconButton(
           icon: Icon(Icons.arrow_back_ios_outlined, color: Color(0xFFf4f4f1),
             size: 25,),
           onPressed: () {

           },
         ),
         backgroundColor: Color(0xFF3b051a),

      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: _pickedImage != null
                    ? FileImage(_pickedImage!)
                    : (avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : AssetImage('assets/avatar.png')) as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            buildTextField(label: "Tên hiển thị", controller: nameController),
            SizedBox(height: 15),
            buildTextField(label: "Tên Studio",controller: studioName),
            SizedBox(height: 15),
            buildTextField(label:"Số điện thoại",controller:  phoneController),
            SizedBox(height: 15),
            buildTextField(label:"Nhập số nhà và tên đường",controller:  _addressController),
            SizedBox(height: 20),
            buildDropdown(
              hint: 'Tỉnh/Thành phố',
              value: selectedProvince,
              items: provinceNames,
              onChanged: (value) {
                setState(() {
                  selectedProvince = value;
                  selectedDistrict = null;
                  selectedWard = null;
                });
              },
            ),
            SizedBox(height: 15),
            buildDropdown(
              hint: 'Quận/Huyện',
              value: selectedDistrict,
              items: districtNames,
              onChanged: (value) {
                setState(() {
                  selectedDistrict = value;
                  selectedWard = null;
                });
              },
            ),
            SizedBox(height: 15),
            buildDropdown(
              hint: 'Phường/Xã',
              value: selectedWard,
              items: wardNames,
              onChanged: (value) {
                setState(() {
                  selectedWard = value;
                });
              },
            ),
            SizedBox(height: 15),
            buildTextField(label:"Email", controller: emailController),
            SizedBox(height: 15),
            buildTextField(label:"Mô tả", controller: studioBio, maxLines: 3),
            // buildTextField("Mật khẩu", passwordController, obscure: true), // nếu cần
            SizedBox(height: 30),
            SizedBox(
              width: 500, // Điều chỉnh kích thước theo ý muốn
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3b051a),
                  padding: EdgeInsets.symmetric(vertical: 15), // Giữ khoảng cách hợp lý
                ),
                child: Text("Đăng kí", style: TextStyle(fontSize: 18, color: Color(0xFFf1f1f4))),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(225, 219, 215, 1.0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        maxLines: maxLines,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: label, // Sử dụng hintText thay vì labelText để giống Dropdown
          border: InputBorder.none, // Loại bỏ đường viền mặc định
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận đăng ký"),
          content: Text("Bạn có chắc muốn tạo tài khoản Studio không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                createStudioAccount(context,widget.userID);

              },
              child: Text("Xác nhận"),
            ),
          ],
        );
      },
    );
  }
  Widget buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(225, 219, 215, 1.0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), // Căn chỉnh khoảng cách
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(hint),
            value: value,
            items: items.map((name) => DropdownMenuItem<String>(
              value: name,
              child: Text(name, overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
