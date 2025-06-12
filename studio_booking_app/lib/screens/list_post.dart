
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'create_post.dart';

//co StudioID
final supabase = Supabase.instance.client;

class PostListPage extends StatefulWidget {
  final int studioID;
  const PostListPage({Key? key, required this.studioID}) : super(key: key);

  @override
  _PostListPageState createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _posts = [];
  // Sử dụng Set<int> để lưu postID được chọn
  Set<int> _selectedPostIDs = {};

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      // 1. Lấy danh sách ServicePackage theo studioID để có danh sách spIDs
      final spResponse = await supabase
          .from('ServicePackage')
          .select()
          .eq('studioID', widget.studioID) as List<dynamic>;
      final servicePackages =
      List<Map<String, dynamic>>.from(spResponse);
      final spIDs = servicePackages.map((sp) => sp['spID']).toList();

      if (spIDs.isEmpty) {
        setState(() {
          _posts = [];
          _isLoading = false;
        });
        return;
      }

      // 2. Lấy danh sách Post có spID thuộc danh sách spIDs
      // Thay vì dùng .in, ta dùng .filter với toán tử "in", truyền chuỗi giá trị
      final spIDsString = '(${spIDs.join(',')})';
      final postResponse = await supabase
          .from('Post')
          .select()
          .filter('spID', 'in', spIDsString) as List<dynamic>;
      final postsList = List<Map<String, dynamic>>.from(postResponse);
      final postIDs = postsList.map((post) => post['postID']).toList();

      if (postIDs.isEmpty) {
        setState(() {
          _posts = [];
          _isLoading = false;
        });
        return;
      }

      // 3. Lấy danh sách ảnh từ PostPhotos có postID nằm trong danh sách postIDs
      final postIDsString = '(${postIDs.join(',')})';
      final photoResponse = await supabase
          .from('PostPhotos')
          .select()
          .filter('postID', 'in', postIDsString) as List<dynamic>;
      final photosList =
      List<Map<String, dynamic>>.from(photoResponse);

      // 4. Nhóm ảnh theo postID
      final Map<int, List<Map<String, dynamic>>> postPhotosMap = {};
      for (final photo in photosList) {
        final int pid = photo['postID'] as int;
        postPhotosMap.putIfAbsent(pid, () => []).add(photo);
      }

      // 5. Ghép từng post với danh sách ảnh tương ứng (nếu có)
      final joinedPosts = postsList.map((post) {
        post['photos'] = postPhotosMap[post['postID']] ?? [];
        return post;
      }).toList();

      setState(() {
        _posts = joinedPosts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi khi lấy bài post: $e");
      setState(() {
        _posts = [];
        _isLoading = false;
      });
    }
  }
  Future<void> deleteSelectedPosts() async {
    try {
      if (_selectedPostIDs.isNotEmpty) {
        final List<int> selectedIDs = _selectedPostIDs.toList();
        final idsString = '(${selectedIDs.join(',')})';

        // --- Xóa storage folder cho từng post ---
        for (final postId in selectedIDs) {
          final String folderPath = postId.toString();
          try {
            // List các file trong folder (nếu có)
            final List<dynamic> fileList = await supabase.storage
                .from('post-image')
                .list(path: folderPath);
            // Giả sử mỗi phần tử trong fileList có thuộc tính 'name'
            final List<String> filePaths = fileList.map<String>((file) {
              // Ví dụ: nếu file['name'] là tên file, thì file path là "folderPath/filename"
              return '$folderPath/${file['name']}';
            }).toList();

            if (filePaths.isNotEmpty) {
              await supabase.storage
                  .from('post-image')
                  .remove(filePaths);
            }
          } catch (storageError) {
            // Nếu có lỗi khi xóa file trong storage, hãy in log hoặc xử lý theo nghiệp vụ
            debugPrint("Lỗi xóa folder của postID $postId: $storageError");
          }
        }

        // --- Xóa các dữ liệu phụ thuộc ---
        // 1. Xóa các ảnh liên quan trong PostPhotos
        await supabase
            .from('PostPhotos')
            .delete()
            .filter('postID', 'in', idsString);

        // 2. Xóa các comment liên quan trong Comments
        await supabase
            .from('Comments')
            .delete()
            .filter('postID', 'in', idsString);

        // 3. Xóa bài post trong Post
        await supabase
            .from('Post')
            .delete()
            .filter('postID', 'in', idsString);

        setState(() {
          _posts.removeWhere(
                  (post) => selectedIDs.contains(post['postID'] as int));
          _selectedPostIDs.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Xóa bài post thành công.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lỗi xóa bài post: $e")));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Bài viết',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFf4f4f1)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined, color:  Color(0xFFf4f4f1),size: 25,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF3b051a),
        actions: [
          if (_selectedPostIDs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete,color:  Color(0xFFf4f4f1),size: 25,),
              onPressed: () async {
                final bool confirmed = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Xác nhận"),
                      content: const Text(
                          "Bạn có chắc muốn xóa các bài post đã chọn?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Hủy"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Xóa"),
                        ),
                      ],
                    );
                  },
                );
                if (confirmed) {
                  await deleteSelectedPosts();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Trống',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color:  Color(0xFF3b051a)),
            ),
            SizedBox(height: 8),
            Text(
              'Hiện tại chưa có bài viết nào.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          final String content = post["content"] ?? "";
          final String createdDate =
              post["createdDate"]?.toString() ?? "N/A";
          final String spTag = post["spTag"] ?? "";
          final int likes = post["likes"] ?? 0;
          final int postID = post["postID"] as int;
          final bool isSelected =
          _selectedPostIDs.contains(postID);

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              onLongPress: () {
                setState(() {
                  if (isSelected) {
                    _selectedPostIDs.remove(postID);
                  } else {
                    _selectedPostIDs.add(postID);
                  }
                });
              },
              onTap: () {
                if (_selectedPostIDs.isNotEmpty) {
                  setState(() {
                    if (isSelected) {
                      _selectedPostIDs.remove(postID);
                    } else {
                      _selectedPostIDs.add(postID);
                    }
                  });
                } else {
                  // Có thể chuyển sang trang chi tiết bài post nếu cần
                }
              },
              leading: (post["photos"] != null &&
                  (post["photos"] as List).isNotEmpty)
                  ? Image.network(
                post["photos"][0]["photoURL"] ?? "",
                width: 85,
                height: 100,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 85,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.image,
                    color: Color(0xFF3b051a)),
              ),
              title: Text(content,style: TextStyle(fontWeight: FontWeight.w500),),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ngày đăng: $createdDate"),
                  Text("Tag: $spTag"),
                  Text("Likes: $likes"),
                ],
              ),
              trailing: Checkbox(
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedPostIDs.add(postID);
                    } else {
                      _selectedPostIDs.remove(postID);
                    }
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:  Color(0xFF3b051a),
        onPressed: () async {

          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePost(studioID: widget.studioID)),
          );
          if(result==true) {
            await fetchPosts();
          }
        },
        child: Icon(Icons.add, color: Colors.white,size: 28,),
      ),
    );
  }
}
