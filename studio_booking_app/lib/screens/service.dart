

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_service.dart';
import 'edit_service.dart';


class ServicesScreen extends StatefulWidget {
  final int studioID;
  const ServicesScreen({Key? key, required this.studioID}) : super(key: key);

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final supabase = Supabase.instance.client;
  bool isEditing = false;
  Future<List<Map<String, dynamic>>>? _servicesFuture;
  Future<List<Map<String, dynamic>>> fetchServices() async {
    final List<Map<String, dynamic>> services = await supabase
        .from('ServicePackage')
        .select('*, ServiceImages(*)')
        .eq('studioID', widget.studioID);
    return services;
  }
  void loadServices() {
    _servicesFuture = supabase
        .from('ServicePackage')
        .select('*, ServiceImages(*)')
        .eq('studioID', widget.studioID);
    setState(() {});
  }

  Future<void> _deleteService(String spID) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text(
            "Bạn có chắc muốn xóa dịch vụ này và tất cả các booking, post, images, comments liên quan không?"),
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
      ),
    );

    if (confirmed == true) {
      try {
        final postsData = await supabase
            .from('Post')
            .select('postID')
            .eq('spID', spID);

        final postsList = postsData as List<dynamic>? ?? [];
        final postIDs = postsList.map((e) => e['postID'].toString()).toList();

        if (postIDs.isNotEmpty) {
          final formattedIDs = '(${postIDs.join(",")})';
          await supabase
              .from('Comments')
              .delete()
              .filter('postID', 'in', formattedIDs);
        }

        await supabase.from('Post').delete().eq('spID', spID);
        await supabase.from('Booking').delete().eq('spID', spID);
        await supabase.from('ServiceImages').delete().eq('spID', spID);
        await supabase.from('ServicePackage').delete().eq('spID', spID);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa dịch vụ và tất cả dữ liệu liên quan thành công")),
        );
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi xóa: $e")),
        );
      }
    }
  }
  void initState() {
    super.initState();
    loadServices(); // gọi lúc khởi tạo
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Dịch vụ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFf4f4f1)),
        ),
        leading: IconButton(
          icon: const Icon(
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
            icon: Icon(
              isEditing ? Icons.close : Icons.edit,
              color: const Color(0xFFf4f4f1),
              size: 25,
            ),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
        backgroundColor: const Color(0xFF3b051a),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Lỗi: ${snapshot.error}",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else if (snapshot.hasData) {
            final services = snapshot.data!;
            if (services.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Trống',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3b051a)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hiện tại chưa có dịch vụ nào.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final spID = service['spID'];
                final spName = service['spName'] ?? '';
                final spPrice = service['spPrice']?.toString() ?? '0';
                final spDuration = service['spDuration']?.toString() ?? '0';

                String? imageUrl;
                final List<dynamic>? imagesList = service['ServiceImages'];
                if (imagesList != null && imagesList.isNotEmpty) {
                  imageUrl = imagesList[0]['SpImgURL'];
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: ListTile(
                    leading: imageUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.image, color: Colors.grey[700]),
                    ),
                    title: Text(
                      spName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Giá: $spPrice - ${spDuration} phút"),
                    trailing: isEditing
                        ? IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFF3b051a)),
                      onPressed: () {
                        _deleteService(spID);
                      },
                    )
                        : IconButton(
                        onPressed: () async {
                          if (!isEditing) {
                            final shouldReload = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditService(service: service)
                              ),
                            );
                            if (shouldReload == true) {
                              loadServices();
                            }
                          }

                        },
                        icon: Icon(Icons.keyboard_arrow_right , size: 30, color: Color(0xFF3b051a))
                    ),

                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3b051a),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateService(studioID: widget.studioID),
            ),
          ).then((_) => setState(() {}));
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
