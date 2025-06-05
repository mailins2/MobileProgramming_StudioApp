import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:studio_booking_app/constants/colorpalette.dart';
import 'package:studio_booking_app/constants/text-font.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:studio_booking_app/screens/index.dart';
import 'package:provider/provider.dart';
import 'package:studio_booking_app/providers/userProvider.dart';
import 'package:studio_booking_app/models/userModel.dart';

Widget buildDropdown({
  required String hint,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      border: Border.all(color: grey),
      borderRadius: BorderRadius.circular(10),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Text(hint),
        value: value,
        items: items
            .map((name) => DropdownMenuItem<String>(
          value: name,
          child: Text(name, overflow: TextOverflow.ellipsis),
        ))
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

class SignUpInfo extends StatefulWidget {
  final int userId;
  SignUpInfo({required this.userId});

  @override
  State<SignUpInfo> createState() => _SignUpInfoState();
}

class _SignUpInfoState extends State<SignUpInfo> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  List<dynamic> provincesData = [];
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;
  Map<String, dynamic>? _userInfo;

  File? _newAvatarFile;

  @override
  void initState() {
    super.initState();
    loadProvinces();
    fetchUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> loadProvinces() async {
    final jsonStr = await rootBundle.loadString('lib/assets/data/data.json');
    final List<dynamic> jsonData = json.decode(jsonStr);
    setState(() {
      provincesData = jsonData;
    });
  }

  Future<void> fetchUserInfo() async {
    final response = await Supabase.instance.client
        .from('UserAcoount')
        .select()
        .eq('userId', widget.userId)
        .maybeSingle();

    if (response != null) {
      setState(() {
        _userInfo = response;
        _nameController.text = _userInfo!['userFullName'] ?? '';
        _emailController.text = _userInfo!['userEmail'] ?? '';
        final fullAddress = _userInfo!['userAddress'] ?? '';
        parseAddress(fullAddress);
      });
    }
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

  Future<bool> isEmailDuplicate(String email) async {
    final response = await Supabase.instance.client
        .from('UserAcoount')
        .select('userEmail')
        .eq('userEmail', email)
        .neq('userId', widget.userId)
        .maybeSingle();

    return response != null;
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

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newAvatarFile = File(pickedFile.path);
      });
    }
  }

  ImageProvider<Object> getAvatarImage() {
    if (_newAvatarFile != null) {
      return FileImage(_newAvatarFile!);
    }

    final avatarUrl = _userInfo?['userAvatar']?.trim();
    if (avatarUrl != null &&
        (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'))) {
      return NetworkImage(avatarUrl);
    }

    return const AssetImage('lib/assets/images/avatar-default.jpg');
  }

  @override
  Widget build(BuildContext context) {
    final provinceNames = getProvinceNames();
    final districtNames = getDistrictNames();
    final wardNames = getWardNames();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: red,
        title: Center(
          child: Text(
            'Booking Studio',
            style: TextStyle(
              fontFamily: logo_font,
              fontWeight: logo_fontweight,
              fontSize: 25,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Thông tin tài khoản',
                    style: TextStyle(
                      color: red,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      await _pickAndUploadAvatar();
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: getAvatarImage(),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  buildTextFormField(
                    hintText: 'Nhập họ tên',
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập họ tên';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  buildTextFormField(
                    hintText: 'Nhập email',
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  buildTextFormField(
                    hintText: 'Nhập số nhà và tên đường',
                    controller: _addressController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập địa chỉ';
                      }
                      return null;
                    },
                  ),
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
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (selectedProvince == null ||
                            selectedDistrict == null ||
                            selectedWard == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Vui lòng chọn đầy đủ Tỉnh/TP, Quận/Huyện và Phường/Xã'),
                            ),
                          );
                          return;
                        }

                        final emailExists = await isEmailDuplicate(
                            _emailController.text.trim());

                        if (emailExists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Email đã được sử dụng, vui lòng chọn email khác.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        String? avatarUrl;

                        if (_newAvatarFile != null) {
                          final extension = path.extension(_newAvatarFile!.path); // .jpg, .png...
                          final storagePath = '${widget.userId}$extension';

                          try {
                            // Xóa ảnh cũ nếu có
                            final oldAvatarUrl = _userInfo?['userAvatar'];
                            if (oldAvatarUrl != null && oldAvatarUrl.toString().isNotEmpty) {
                              final filePath = oldAvatarUrl.split('/').last;
                              await Supabase.instance.client.storage
                                  .from('user-avatar')
                                  .remove([filePath]);
                            }

                            // Upload ảnh mới
                            await Supabase.instance.client.storage
                                .from('user-avatar')
                                .upload(storagePath, _newAvatarFile!,
                                fileOptions: const FileOptions(upsert: true));

                            avatarUrl = Supabase.instance.client.storage
                                .from('user-avatar')
                                .getPublicUrl(storagePath);
                          } catch (e) {
                            print('Lỗi upload ảnh: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Không thể cập nhật ảnh đại diện.')),
                            );
                            return;
                          }
                        }
                        final fullAddress =
                            '${_addressController.text}, $selectedWard, $selectedDistrict, $selectedProvince';

                        final updateData = {
                          'userFullName': _nameController.text.trim(),
                          'userEmail': _emailController.text.trim(),
                          'userAddress': fullAddress,
                        };

                        if (avatarUrl != null) {
                          updateData['userAvatar'] = avatarUrl;
                        }

                        try {
                          await Supabase.instance.client
                              .from('UserAcoount')
                              .update(updateData)
                              .eq('userId', widget.userId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cập nhật thông tin thành công.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Default(), // hoặc truyền userId nếu cần
                            ),
                          );
                          _newAvatarFile = null;
                          fetchUserInfo(); // refresh
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Có lỗi xảy ra khi cập nhật thông tin: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Text('Lưu'),
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(fontSize: 20),
                      padding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                      minimumSize: Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField({
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: grey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
        validator: validator,
      ),
    );
  }
}
