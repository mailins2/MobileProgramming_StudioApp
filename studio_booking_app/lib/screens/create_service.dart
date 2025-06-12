import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class CreateService extends StatefulWidget {
  final int studioID;

  const CreateService({Key? key, required this.studioID}) : super(key: key);

  @override
  _CreateServicePageState createState() => _CreateServicePageState();
}

class _CreateServicePageState extends State<CreateService> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _spNameController = TextEditingController();
  final TextEditingController _spPriceController = TextEditingController();
  final TextEditingController _spDurationController = TextEditingController();
  final TextEditingController _spDescriptionController = TextEditingController();
  final TextEditingController _spRawImgTimeController = TextEditingController();
  final TextEditingController _spEditedImgTimeController = TextEditingController();
  final TextEditingController _spEditedReceiveController = TextEditingController();
  final TextEditingController _spBookingDepositController = TextEditingController();

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _spNameController.dispose();
    _spPriceController.dispose();
    _spDurationController.dispose();
    _spDescriptionController.dispose();
    _spRawImgTimeController.dispose();
    _spEditedImgTimeController.dispose();
    _spEditedReceiveController.dispose();
    _spBookingDepositController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _pickedImage = picked;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi chọn ảnh: $e")),
      );
    }
  }

  Future<String> _uploadServiceImage(String spID) async {
    if (_pickedImage == null) {
      throw Exception("Không có ảnh nào được chọn!");
    }

    final folderPath = spID;
    final fileBytes = await _pickedImage!.readAsBytes();
    final fileExt = p.extension(_pickedImage!.path);
    final fileName = '1$fileExt';
    final filePath = '$folderPath/$fileName';

    try {
      await supabase.storage.from('service-image').uploadBinary(
        filePath,
        fileBytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final publicUrl = supabase.storage.from('service-image').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception("Upload ảnh thất bại: $e");
    }
  }

  Future<void> _submitService() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn một ảnh!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final spName = _spNameController.text.trim();
    final spPrice = double.tryParse(_spPriceController.text.trim()) ?? 0.0;
    final spDuration = int.tryParse(_spDurationController.text.trim());
    final spDescription = _spDescriptionController.text.trim();
    final spRawImgTime = int.tryParse(_spRawImgTimeController.text.trim());
    final spEditedImgTime = int.tryParse(_spEditedImgTimeController.text.trim());
    final spEditedReceive = int.tryParse(_spEditedReceiveController.text.trim());
    final spBookingDeposit = int.tryParse(_spBookingDepositController.text.trim()) ?? 0;

    try {
      final response = await supabase
          .from('ServicePackage')
          .insert({
        'studioID': widget.studioID,
        'spName': spName,
        'spPrice': spPrice,
        'spDuration': spDuration,
        'spDescription': spDescription,
        'spRawImgTime': spRawImgTime,
        'spEditedImgTime': spEditedImgTime,
        'spEditedReceive': spEditedReceive,
        'spBookingDeposit': spBookingDeposit,
      })
          .select('spID')
          .single();

      final String spID = response['spID'].toString();

      final imageUrl = await _uploadServiceImage(spID);

      await supabase.from('ServiceImages').insert({
        'spID': spID,
        'SpImgURL': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Tạo dịch vụ & upload ảnh thành công!",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          backgroundColor: Color(0xFF3b051a),
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Lỗi khi tạo dịch vụ: $e",
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tạo dịch vụ mới",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFf4f4f1)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined, color: Color(0xFFf4f4f1),
            size: 25,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF3b051a),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              buildImagePicker(),
              const SizedBox(height: 20),
              TextFormField(
                controller: _spNameController,
                style: TextStyle(fontSize: 20, color: Color(0xFF221516)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tên dịch vụ',
                  labelStyle:
                  TextStyle(fontSize: 20, color: Color(0xFF3b051a)),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 18, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Color(0xFF3b051a), width: 1.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập tên dịch vụ";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _spPriceController,
                style: TextStyle(fontSize: 20, color: Color(0xFF221516)),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Giá',
                  labelStyle:
                  TextStyle(fontSize: 20, color: Color(0xFF3b051a)),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 18, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Color(0xFF3b051a), width: 1.0),
                  ),
                  suffixText: 'VND',
                  suffixStyle:
                  TextStyle(fontSize: 18, color: Color(0xFF3b051a)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập giá dịch vụ";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _spDurationController,
                style: TextStyle(fontSize: 20, color: Color(0xFF221516)),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Thời gian làm (ngày)',
                  labelStyle:
                  TextStyle(fontSize: 20, color: Color(0xFF3b051a)),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 18, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Color(0xFF3b051a), width: 1.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập thời gian làm";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SizedBox(height: 20),
              // Đặt cọc (spBookingDeposit)
              TextFormField(
                controller: _spBookingDepositController,
                style: TextStyle(fontSize: 20, color: Color(0xFF221516)),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Đặt cọc',
                  labelStyle:
                  TextStyle(fontSize: 20, color: Color(0xFF3b051a)),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 18, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Color(0xFF3b051a), width: 1.0),
                  ),
                  suffixText: 'VND',
                  suffixStyle:
                  TextStyle(fontSize: 18, color: Color(0xFF3b051a)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập số tiền đặt cọc";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Mô tả dịch vụ (spDescription)
              TextFormField(
                controller: _spDescriptionController,
                style: TextStyle(fontSize: 20, color: Color(0xFF221516)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Mô tả dịch vụ',
                  labelStyle:
                  TextStyle(fontSize: 20, color: Color(0xFF3b051a)),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 18, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Color(0xFF3b051a), width: 1.0),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập mô tả dịch vụ";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Thời gian ảnh gốc (spRawImgTime)
              TextFormField(
                controller: _spRawImgTimeController,
                style: TextStyle(fontSize: 20, color: Color(0xFF221516)),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Thời gian lấy ảnh gốc (ngày)',
                  labelStyle:
                  TextStyle(fontSize: 20, color: Color(0xFF3b051a)),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 18, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Color(0xFF3b051a), width: 1.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Thời gian ảnh sau chỉnh (spEditedImgTime)
              TextFormField(
                controller: _spEditedImgTimeController,
                style: TextStyle(fontSize: 20, color: Color(0xFF221516)),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Thời gian lấy ảnh chỉnh (ngày)',
                  labelStyle:
                  TextStyle(fontSize: 20, color: Color(0xFF3b051a)),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 18, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Color(0xFF3b051a), width: 1.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Số lượng ảnh nhận chỉnh (spEditedReceive)
              TextFormField(
                controller: _spEditedReceiveController,
                style: TextStyle(fontSize: 20, color: Color(0xFF221516)),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Số lượng ảnh nhận chỉnh',
                  labelStyle:
                  TextStyle(fontSize: 20, color: Color(0xFF3b051a)),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 18, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                    BorderSide(color: Color(0xFF3b051a), width: 1.0),
                  ),
                ),
              ),
              SizedBox(height: 40),
              const SizedBox(height: 16),


              _isLoading
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                onTap: () {
                  _submitService();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  decoration: BoxDecoration(
                    color: Color(0xFF3b051a), // Màu nền thay vì gradient
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Center(
                      child:  TextButton(
                          onPressed: () {
                            _submitService();
                          },
                          child: Text("Đăng", style: TextStyle(color: Color(0xFFf4f4f1),fontSize: 18,fontWeight: FontWeight.bold),))
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
  Widget buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chọn ảnh:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3b051a),
            ),
          ),
          const SizedBox(height: 10),
          _pickedImage == null
              ? // Nếu chưa chọn ảnh, hiển thị container mời người dùng chọn ảnh
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Nhấn để chọn ảnh",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              : // Nếu đã chọn ảnh, hiển thị ảnh được chọn ở dạng fullscreen trong container
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_pickedImage!.path),
              height: 450,
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter
            ),
          ),
          const SizedBox(height: 10),
          // Hiển thị nút "Thay đổi ảnh" khi đã có ảnh
          _pickedImage != null
              ? ElevatedButton.icon(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3b051a),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 5,
            ),
            icon: const Icon(
              Icons.refresh,
              size: 24,
            ),
            label: const Text(
              "Thay đổi ảnh",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
              : Container(), // Nếu chưa chọn ảnh, không cần nút thay đổi
        ],
      ),
    );
  }
}
