
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditService extends StatefulWidget {
  final Map<String, dynamic> service;

  const EditService({Key? key, required this.service}) : super(key: key);

  @override
  _EditServiceState createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _depositController;
  late final TextEditingController _rawImgTimeController;
  late final TextEditingController _editedImgTimeController;
  late final TextEditingController _editedReceiveController;

  final supabase = Supabase.instance.client;
  late final int spID;
  String? serviceImageUrl; // Biến lưu URL ảnh từ ServiceImages
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    spID = s['spID'];

    _nameController = TextEditingController(text: s["spName"] ?? "");
    _priceController = TextEditingController(text: s["spPrice"]?.toString() ?? "");
    _durationController = TextEditingController(text: s["spDuration"]?.toString() ?? "");
    _descriptionController = TextEditingController(text: s["spDescription"] ?? "");
    _depositController = TextEditingController(text: s["spBookingDeposit"]?.toString() ?? "");
    _rawImgTimeController = TextEditingController(text: s["spRawImgTime"]?.toString() ?? "");
    _editedImgTimeController = TextEditingController(text: s["spEditedImgTime"]?.toString() ?? "");
    _editedReceiveController = TextEditingController(text: s["spEditedReceive"]?.toString() ?? "");

    // Tải ảnh từ ServiceImages khi khởi tạo
    _loadServiceImage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _depositController.dispose();
    _rawImgTimeController.dispose();
    _editedImgTimeController.dispose();
    _editedReceiveController.dispose();
    super.dispose();
  }

  // Hàm lấy ảnh từ ServiceImages
  Future<void> _loadServiceImage() async {
    try {
      final images = await fetchServiceImages(spID);
      if (images.isNotEmpty) {
        setState(() {
          serviceImageUrl = images.first['SpImgURL']; // Lấy ảnh đầu tiên
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải ảnh: $e")),
      );
    }
  }

  // Hàm lấy danh sách ảnh từ ServiceImages
  Future<List<Map<String, dynamic>>> fetchServiceImages(int spID) async {
    final response = await supabase
        .from('ServiceImages')
        .select()
        .eq('spID', spID);
    return response;
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi chọn ảnh: $error")),
      );
    }
  }
  //
  // // Hàm tải ảnh lên Supabase Storage và lưu URL vào ServiceImages
  // Future<void> _uploadImage() async {
  //   if (_selectedImage == null) return;
  //   try {
  //     final fileName = 'service_${spID}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //     await supabase.storage
  //         .from('service-image')
  //         .upload(fileName, File(_selectedImage!.path));
  //     final imageUrl = supabase.storage.from('service-image').getPublicUrl(fileName);
  //
  //     // Lưu URL vào bảng ServiceImages
  //     await supabase.from('ServiceImages').insert({
  //       'spID': spID,
  //       'SpImgURL': imageUrl,
  //     });
  //
  //     setState(() {
  //       serviceImageUrl = imageUrl; // Cập nhật URL để hiển thị
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Tải ảnh lên thành công!")),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Lỗi tải ảnh: $e")),
  //     );
  //   }
  // }
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      // Tạo đường dẫn thư mục theo spID
      final folderPath = '$spID';
      final fileExt = _selectedImage!.path.split('.').last; // Lấy phần mở rộng
      final fileName = '1.$fileExt'; // Tên file cố định, ví dụ: 1.jpg
      final filePath = '$folderPath/$fileName'; // Đường dẫn: spID/1.jpg

      // Xóa ảnh cũ trong bucket nếu tồn tại
      if (serviceImageUrl != null) {
        try {
          final oldFilePath = Uri.parse(serviceImageUrl!).pathSegments.last;
          await supabase.storage.from('service-image').remove([oldFilePath]);
          print("Xoa anh thanh cu thanh cog ${oldFilePath}");
        } catch (e) {
          print('Lỗi khi xóa ảnh cũ: $e'); // Ghi log, không ném lỗi để tiếp tục tải ảnh mới
        }
      }

      // Đọc dữ liệu ảnh dưới dạng bytes
      final fileBytes = await _selectedImage!.readAsBytes();
      print('Du lieu anh: $fileBytes');
      // Tải ảnh lên Supabase Storage
      await supabase.storage.from('service-image').uploadBinary(
        filePath,
        fileBytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      print('Tải ảnh lên storage thanh cong!');
      // Lấy URL công khai của ảnh
      final imageUrl = supabase.storage.from('service-image').getPublicUrl(filePath);
      print('Public URL: $imageUrl');
      // Lưu URL vào bảng ServiceImages
      await supabase.from('ServiceImages').insert({
        'spID': spID,
        'SpImgURL': imageUrl,
      });

      // Cập nhật serviceImageUrl để hiển thị ảnh mới
      setState(() {
        serviceImageUrl = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tải ảnh lên thành công!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải ảnh: $e")),
      );
    }
  }
  // Hàm cập nhật dịch vụ và ảnh
  Future<void> _updateService() async {
    final updatedData = {
      "spName": _nameController.text.trim(),
      "spPrice": double.tryParse(_priceController.text) ?? 0.0,
      "spDuration": int.tryParse(_durationController.text),
      "spDescription": _descriptionController.text.trim(),
      "spBookingDeposit": int.tryParse(_depositController.text),
      "spRawImgTime": int.tryParse(_rawImgTimeController.text),
      "spEditedImgTime": int.tryParse(_editedImgTimeController.text),
      "spEditedReceive": int.tryParse(_editedReceiveController.text),
    };

    try {
      // Cập nhật thông tin dịch vụ
      final response = await supabase
          .from('ServicePackage')
          .update(updatedData)
          .eq('spID', spID)
          .select()
          .maybeSingle();

      // Tải ảnh lên nếu có ảnh mới
      await _uploadImage();

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy dịch vụ để cập nhật.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật dịch vụ thành công!')),
        );
        Navigator.pop(context, true);
      }
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi Supabase: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi không xác định: $e")),
      );
    }
    print("Đang cập nhật dịch vụ spID: $spID");
    print("Dữ liệu gửi lên: $updatedData");
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        maxLines: maxLines,
        // Chỉ cho phép nhập số nếu keyboardType là số
        inputFormatters: keyboardType == TextInputType.number
            ? [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')), // Cho phép số và dấu chấm
          // Nếu chỉ muốn số nguyên, dùng: FilteringTextInputFormatter.digitsOnly
        ]
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 20, color: Color(0xFF3b051a)),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
                color: Color.fromRGBO(225, 219, 215, 0.5), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
                color: Color.fromRGBO(225, 219, 215, 1.0), width: 1.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label không được để trống';
          }
          if (keyboardType == TextInputType.number) {
            // Kiểm tra xem giá trị có phải là số hợp lệ không
            if (double.tryParse(value) == null) {
              return 'Vui lòng nhập số hợp lệ cho $label';
            }
            // Kiểm tra số không âm
            if (label == "Giá" || label == "Đặt cọc") {
              if (double.parse(value) < 0) {
                return '$label không được nhỏ hơn 0';
              }
            }
            // Kiểm tra số nguyên không âm cho các trường khác
            if (label == "Thời gian (ngày)" ||
                label == "Ảnh gốc (ngày)" ||
                label == "Ảnh chỉnh (ngày)" ||
                label == "Ảnh nhận chỉnh") {
              if (int.tryParse(value) == null || int.parse(value) < 0) {
                return '$label phải là số nguyên không âm';
              }
            }
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chỉnh sửa dịch vụ",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFf4f4f1),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3b051a),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_outlined, size: 25),
          color: const Color(0xFFf1f1f4),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    image: _selectedImage != null
                        ? DecorationImage(
                      image: FileImage(File(_selectedImage!.path)),
                      fit: BoxFit.cover,
                    )
                        : serviceImageUrl != null
                        ? DecorationImage(
                      image: NetworkImage(serviceImageUrl!),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) => null,
                    )
                        : const DecorationImage(
                      image: AssetImage('lib/assets/imgs/placeholder.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: _selectedImage == null && serviceImageUrl == null
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "Chọn ảnh từ thư viện",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                      : null,
                ),
              ),
            ),
            SizedBox(height: 20,),
            _buildField("Tên dịch vụ", _nameController),
            _buildField("Giá", _priceController, keyboardType: TextInputType.number),
            _buildField("Thời gian (ngày)", _durationController, keyboardType: TextInputType.number),
            _buildField("Đặt cọc", _depositController, keyboardType: TextInputType.number),
            _buildField("Ảnh gốc (ngày)", _rawImgTimeController, keyboardType: TextInputType.number),
            _buildField("Ảnh chỉnh (ngày)", _editedImgTimeController, keyboardType: TextInputType.number),
            _buildField("Ảnh nhận chỉnh", _editedReceiveController, keyboardType: TextInputType.number),
            _buildField("Mô tả", _descriptionController, maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _updateService,
              icon: const Icon(Icons.save),
              label: const Text("Cập nhật"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                backgroundColor: const Color(0xFF3b051a),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
