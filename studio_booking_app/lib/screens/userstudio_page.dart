import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studio_booking_app/screens/chitietdv.dart';

class UserStudioPage extends StatefulWidget {
  final int studioID;
  const UserStudioPage({Key? key, required this.studioID}) : super(key: key);

  @override
  State<UserStudioPage> createState() => UserStudioPageState();
}

class UserStudioPageState extends State<UserStudioPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StudioAccount? studioInfo;
  List<ServicePackage> services = [];
  List<Post> posts = [];
  Map<int, String> postThumbnails = {}; // postID -> ảnh đại diện
  Map<int, ServicePackage> servicePackages = {}; // spID -> ServicePackage

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudioData();
  }


  Future<void> _loadStudioData() async {
    // Xóa dữ liệu cũ trước khi load mới
    services.clear();
    posts.clear();
    postThumbnails.clear();
    servicePackages.clear();

    final responseStudio = await Supabase.instance.client
        .from('StudioAccount')
        .select()
        .eq('studioID', widget.studioID)
        .single();

    final responseServices = await Supabase.instance.client
        .from('ServicePackage')
        .select()
        .eq('studioID', widget.studioID);

    services = (responseServices as List).map((json) => ServicePackage.fromJson(json)).toList();
    servicePackages = {
      for (var sp in services) sp.spID: sp,
    };
    final spIDs = services.map((e) => e.spID).toSet().toList(); // Loại trùng nếu có

    final responsePosts = await Supabase.instance.client
        .from('Post')
        .select()
        .inFilter('spID', spIDs);

    final uniquePosts = <int, Post>{};
    for (var json in responsePosts as List) {
      final post = Post.fromJson(json);
      uniquePosts[post.postID] = post; // loại trùng theo postID
    }
    posts = uniquePosts.values.toList();

    for (var post in posts) {
      final responsePhotos = await Supabase.instance.client
          .from('PostPhotos')
          .select()
          .eq('postID', post.postID)
          .limit(1)
          .maybeSingle();

      if (responsePhotos != null && responsePhotos['photoURL'] != null && responsePhotos['photoURL'].toString().isNotEmpty) {
        postThumbnails[post.postID] = responsePhotos['photoURL'];
      }
    }

    setState(() {
      studioInfo = StudioAccount.fromJson(responseStudio);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F1),
      body: studioInfo == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 45, left: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF3B0510)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    studioInfo!.studioAccountName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            buildStudioProfile(
              Studio(
                imagePath: studioInfo!.studioAvatar,
                name: studioInfo!.studioName,
                follow: studioInfo!.studioFollower,
                danhgia: studioInfo!.studioRate,
                diachi: studioInfo!.studioAddress,
                bio: studioInfo!.studioBio,
                luotdat: studioInfo!.studioBooking,
              ),
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              labelColor: const Color.fromARGB(255, 59, 5, 16),
              indicatorColor: const Color.fromARGB(255, 59, 5, 16),
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(child: Text('Bài viết', style: TextStyle(fontSize: 18))),
                Tab(child: Text('Dịch vụ', style: TextStyle(fontSize: 18))),
                Tab(child: Text('Đánh giá', style: TextStyle(fontSize: 18))),
              ],
            ),
            SizedBox(
              height: 500,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPostsTab(),
                  _buildServicesTab(),
                  const Center(child: Text("Chưa có đánh giá.")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.0,
        childAspectRatio: 0.9,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final thumbnail = postThumbnails[post.postID] ?? 'https://yourdomain.com/default-image.jpg';
        final sp = servicePackages[post.spID];
        final price = sp?.spPrice ?? 0;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Image.network(
                thumbnail,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Text(
                  '${price.toStringAsFixed(0)} đ',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(Icons.filter, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServicesTab() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: services.map((sp) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailDvDemo(spID: sp.spID)),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: getTemplateDv(
              DichVu(
                imagePath: 'lib/assets/images/anh.jpg',
                tendv: sp.spName,
                gia: '${sp.spPrice.toStringAsFixed(0)}đ',
                icon: Icons.arrow_forward_ios,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildStudioProfile(Studio studioInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    studioInfo.imagePath,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('${studioInfo.follow}', 'Theo dõi'),
                    _buildStatColumn('${studioInfo.luotdat}', 'Lượt book'),
                    _buildStatColumn(
                      double.parse('${studioInfo.danhgia}').toStringAsFixed(1),
                      'Đánh giá',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            studioInfo.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 5),
              Text('Khu vực làm việc: ', style: TextStyle(color: Colors.grey[700], fontSize: 15)),
              Expanded(
                child: Text(
                  studioInfo.diachi,
                  style: const TextStyle(color: Color(0xFF3B0510), fontWeight: FontWeight.w500, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.connect_without_contact, size: 18, color: Colors.grey),
              const SizedBox(width: 5),
              Text('Bio: ', style: TextStyle(color: Colors.grey[700], fontSize: 15)),
              Expanded(
                child: Text(
                  studioInfo.bio,
                  style: const TextStyle(color: Color(0xFF3B0510), fontWeight: FontWeight.w500, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
      ],
    );
  }
}

class StudioAccount {
  final int studioID;
  final String studioAccountName;
  final String studioName;
  final int studioFollower;
  final int studioBooking;
  final double studioRate;
  final String studioBio;
  final String studioAddress;
  final String studioAvatar;

  StudioAccount({
    required this.studioID,
    required this.studioAccountName,
    required this.studioName,
    required this.studioFollower,
    required this.studioBooking,
    required this.studioRate,
    required this.studioBio,
    required this.studioAddress,
    required this.studioAvatar,
  });

  factory StudioAccount.fromJson(Map<String, dynamic> json) {
    return StudioAccount(
      studioID: json['studioID'],
      studioAccountName: json['studioAccountName'] ?? '',
      studioName: json['studioName'] ?? '',
      studioFollower: json['studioFollower'] ?? 0,
      studioBooking: json['studioBooking'] ?? 0,
      studioRate: (json['studioRate'] ?? 0).toDouble(),
      studioBio: json['studioBio'] ?? '',
      studioAddress: json['studioAddress'] ?? '',
      studioAvatar: json['studioAvatar'] ?? '',
    );
  }
}

class ServicePackage {
  final int spID;
  final String spName;
  final double spPrice;

  ServicePackage({required this.spID, required this.spName, required this.spPrice});

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    return ServicePackage(
      spID: json['spID'],
      spName: json['spName'] ?? '',
      spPrice: (json['spPrice'] ?? 0).toDouble(),
    );
  }
}

class Studio {
  final String imagePath;
  final String name;
  final int follow;
  final double danhgia;
  final String diachi;
  final String bio;
  final int luotdat;

  Studio({
    required this.imagePath,
    required this.name,
    required this.follow,
    required this.danhgia,
    required this.diachi,
    required this.bio,
    required this.luotdat,
  });
}

class DichVu {
  final String imagePath;
  final String tendv;
  final String gia;
  final IconData icon;

  DichVu({
    required this.imagePath,
    required this.tendv,
    required this.gia,
    required this.icon,
  });
}

class Post {
  final int postID;
  final String content;
  final String spTag;
  final int spID;
  final int likes;

  Post({
    required this.postID,
    required this.content,
    required this.spTag,
    required this.spID,
    required this.likes,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postID: json['postID'],
      content: json['content'] ?? '',
      spTag: json['spTag'] ?? '',
      spID: json['spID'],
      likes: json['likes'] ?? 0,
    );
  }
}

Widget getTemplateDv(DichVu dv) {
  return Row(
    children: [
      const SizedBox(width: 6),
      Container(
        width: 70,
        height: 75,
        child: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Image.asset(dv.imagePath, fit: BoxFit.cover),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        flex: 7,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                dv.tendv,
                style: const TextStyle(
                  color: Color(0xFF3B0510),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                dv.gia,
                style: const TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      const Expanded(child: Icon(Icons.arrow_forward), flex: 1),
    ],
  );
}





