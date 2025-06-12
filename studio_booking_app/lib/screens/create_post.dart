import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'list_service.dart';

class CreatePost extends StatefulWidget {
  final int studioID;
  const CreatePost({Key? key, required this.studioID}) : super(key: key);
  @override
  CreatePostState createState() => CreatePostState();
}

class CreatePostState extends State<CreatePost> {
  Map<String, dynamic>? _selectedService;
  final SupabaseClient _supabase = Supabase.instance.client;
  List<XFile>? _images = [];
  final picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  List<String> _hashtags = [];
  String? _selectedHashtag;

  Future<void> _pickImages() async {
    if (_images != null && _images!.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Chỉ được chọn tối đa 10 ảnh")),
      );
      return;
    }

    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        final remainingSlots = 10 - (_images?.length ?? 0);
        _images!.addAll(pickedFiles.take(remainingSlots));
      });

      if (_images!.length >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã đạt giới hạn 10 ảnh")),
        );
      }
    }
  }


  Future<List<String>> fetchUniqueTags() async {
    try {
      final response = await _supabase.from('Post').select('spTag');
      final tags = response
          .map((e) => e['spTag']?.toString() ?? '')
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .toList();
      return tags;
    } catch (e) {
      print('Lỗi lấy hashtag: $e');
      return [];
    }
  }

  Future<List<String>> uploadImages(String postId) async {
    List<String> urls = [];
    final folderPath = postId;

    for (int i = 0; i < _images!.length; i++) {
      final image = _images![i];
      final fileBytes = await image.readAsBytes();
      final fileExt = p.extension(image.path);
      final fileName = '${i + 1}$fileExt';
      final filePath = '$folderPath/$fileName';

      try {
        // Upload file
        await _supabase.storage.from('post-image').uploadBinary(
          filePath,
          fileBytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

        // Lấy URL công khai
        final publicUrl = _supabase.storage.from('post-image').getPublicUrl(filePath);
        urls.add(publicUrl);

        // Insert vào bảng PostPhotos
        await _supabase.from('PostPhotos').insert({
          'postID': int.parse(postId),
          'photosID': i + 1,
          'photoURL': publicUrl,
        });
      } catch (e) {
        print('Upload or insert error: $e');
        throw Exception('Upload and insert failed: $e');
      }
    }

    return urls;
  }
  void saveProfile() async {

    // Kiểm tra ảnh
    if (_images == null || _images!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Vui lòng chọn ảnh trước khi lưu!",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
      return;
    }

    // Kiểm tra dịch vụ
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Vui lòng chọn dịch vụ!",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
      return;
    }

    final description = _descriptionController.text;

    try {
      // --- Bước 1: Insert vào Post
      final postData = await _supabase
          .from('Post')
          .insert({
        'content': description,
        'spID': _selectedService!['spID'],
        'spTag': _selectedHashtag ?? '',
        'createdDate': DateTime.now().toIso8601String(),
      })
          .select('postID')
          .single();

      final postId = postData['postID'].toString();

      // --- Bước 2: Upload ảnh và ghi vào PostPhotos
      final imageUrls = await uploadImages(postId);
      //
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Thêm bài viết thành công!",
            style: TextStyle(fontSize: 16, color: Color(0xFFf4f4f1)),
          ),
          backgroundColor: Color(0xFF3b051a),
          duration: Duration(seconds: 1), // Hiển thị SnackBar trong 2 giây
        ),
      );

// Chờ 2 giây trước khi chuyển màn
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });

      // Reset UI sau khi thêm bài viết
      setState(() {
        _images = [];
        _selectedHashtag = null;
        _selectedService = null;
        _descriptionController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Lỗi khi upload ảnh: $e",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    loadTags();
  }

  Future<void> loadTags() async {
    final tags = await fetchUniqueTags();
    setState(() {
      _hashtags = tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tạo post mới", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFf4f4f1))),
        centerTitle: true,
        backgroundColor: Color(0xFF3b051a),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined, color: Color(0xFFf4f4f1), size: 25),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Ảnh
            buildImagePicker(),
            // Mô tả
            buildTextField(),
            // Hashtag
            buildHashtagDropdown(),
            // Chọn dịch vụ
            buildServiceSelection(context,widget.studioID),
            // Nút lưu
            SizedBox(height: 50),
            buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget buildImagePicker() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Chọn ảnh:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3b051a))),
          SizedBox(height: 10),
          _images == null || _images!.isEmpty
              ? GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey[700]),
                    SizedBox(height: 10),
                    Text("Nhấn để chọn ảnh", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
          )
              : Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: _images!.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_images![index].path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _images!.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: Icon(Icons.add_photo_alternate),
                label: Text("Thêm ảnh khác"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3b051a),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: TextFormField(
        controller: _descriptionController,
        style: TextStyle(fontSize: 20, color: Color(0xFF221516)),
        decoration: InputDecoration(
          labelText: 'Viết mô tả',
          labelStyle: TextStyle(fontSize: 20, color: Color(0xFF3b051a)),
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        ),
        maxLines: 3,
      ),
    );
  }

  Widget buildHashtagDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tag_outlined, color: Color(0xFF3b051a), size: 25),
              SizedBox(width: 10),
              Text("Hashtag", style: TextStyle(fontSize: 20, color: Color(0xFF3b051a), fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12), // 🎨 Bo góc đẹp hơn
              boxShadow: [ // 🏆 Hiệu ứng đổ bóng nhẹ
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              isExpanded: true,
              menuMaxHeight: 250, // 🚀 Giới hạn dropdown để không che phần trên
              alignment: Alignment.bottomLeft,
              items: _hashtags.map((tag) {
                return DropdownMenuItem<String>(
                  value: tag,
                  child: Text(tag, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)), // 📌 Font chữ rõ nét hơn
                );
              }).toList(),
              value: _selectedHashtag,
              onChanged: (value) {
                setState(() {
                  _selectedHashtag = value;
                });
              },
              hint: Text("Chọn hashtag", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
              dropdownColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  Widget buildServiceSelection(BuildContext context, int studioID) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceListPage(studioID: studioID),
          ),
        );
        // Nếu có kết quả (người dùng đã chọn dịch vụ)
        if (result != null) {
          setState(() {
            _selectedService = result;
          });
        }

      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              const Icon(Icons.edit, color: Color(0xFF3b051a), size: 25),
              const SizedBox(width: 10),
              Text(
                _selectedService != null
                    ? _selectedService!['spName'] ?? 'Chọn dịch vụ'
                    : 'Chọn dịch vụ',
                style: const TextStyle(fontSize: 20, color: Color(0xFF3b051a)),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildSaveButton() {
    return GestureDetector(
      onTap: () {
        saveProfile();

      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        decoration: BoxDecoration(
          color: Color(0xFF3b051a),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: Offset(4, 4)),
          ],
        ),
        child: Center(
          child: Text("Lưu", style: TextStyle(color: Color(0xFFf4f4f1), fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
