import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'detail_service.dart';

// Khởi tạo client Supabase (đã cấu hình khi khởi chạy ứng dụng)
final supabase = Supabase.instance.client;

class ServiceListPage extends StatefulWidget {
  final int studioID;
  const ServiceListPage({Key? key, required this.studioID}) : super(key: key);

  @override
  ServiceListPageState createState() => ServiceListPageState();
}

class ServiceListPageState extends State<ServiceListPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _services = [];
  Map<String, dynamic>? _selectedService;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      // 1. Lấy danh sách ServicePackage theo studioID
      final servicePackages = await supabase
          .from('ServicePackage')
          .select()
          .eq('studioID', widget.studioID)
          .then((value) => (value as List<dynamic>).cast<Map<String, dynamic>>());

      // 2. Lấy danh sách ServiceImages
      final serviceImages = await supabase
          .from('ServiceImages')
          .select()
          .then((value) => (value as List<dynamic>).cast<Map<String, dynamic>>());

      // 3. Ghép mỗi ServicePackage với danh sách ServiceImages có spID tương ứng
      final List<Map<String, dynamic>> joinedServices = servicePackages.map((sp) {
        final mapSp = Map<String, dynamic>.from(sp);
        final images = serviceImages
            .where((si) => si['spID'].toString() == sp['spID'].toString())
            .map((si) => {
          'spImgID': si['spImgID'],
          'SpImgURL': si['SpImgURL'],
        })
            .toList();
        mapSp['images'] = images;
        return mapSp;
      }).toList();

      // Cập nhật trạng thái giao diện
      setState(() {
        _services = joinedServices;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi khi lấy dịch vụ: $e");
      setState(() {
        _services = [];
        _isLoading = false;
      });
    }
  }

  /// Nút "Chọn" được thiết kế theo style của bạn
  Widget buildChooseButton() {
    return GestureDetector(
      onTap: () {
        if (_selectedService != null) {
          Navigator.pop(context, _selectedService);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vui lòng chọn dịch vụ!")),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        decoration: BoxDecoration(
          color: const Color(0xFF3b051a),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Chọn",
            style: TextStyle(
              color: Color(0xFFf4f4f1),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách dịch vụ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFf4f4f1))),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios_outlined,size: 25,), color: Color(0xFFf4f4f1)),
        centerTitle: true,
        backgroundColor: Color(0xFF3b051a),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
          ? const Center(child: Text("Không tìm thấy dịch vụ nào."))
      // Sử dụng ListView.builder để toàn bộ nội dung (card dịch vụ và nút Chọn) được cuộn
          : ListView.builder(
        itemCount: _services.length + 1, // thêm 1 item cho nút "Chọn"
        itemBuilder: (context, index) {
          if (index < _services.length) {
            final service = _services[index];
            final String spName =
                service["spName"] ?? "Không có tên";
            final double spPrice = service["spPrice"] != null
                ? (service["spPrice"] as num).toDouble()
                : 0;
            final bool isSelected = _selectedService != null &&
                _selectedService!["spID"].toString() ==
                    service["spID"].toString();

            return Card(
              margin: const EdgeInsets.all(5),
              color: isSelected ? Colors.blue[100] : null,
              child: ListTile(
                title: Text(spName),
                subtitle: Text("Giá: $spPrice"),
                onTap: () {
                  setState(() {
                    _selectedService = service;
                  });
                },
                // Hiển thị khung cho ảnh:
                // Nếu có ảnh => trưng thị ảnh, nếu không có => khung màu xám.
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: (service['images'] != null &&
                        (service['images'] as List)
                            .isNotEmpty)
                        ? null
                        : Colors.grey[300],
                    image: (service['images'] != null &&
                        (service['images'] as List)
                            .isNotEmpty)
                        ? DecorationImage(
                      image: NetworkImage(
                          service['images'][0]['photoURL'] ??
                              ''),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                ),

                trailing: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_right),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailServicePage(
                          service: service,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            // Thêm nút "Chọn" cuối danh sách
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
              child: buildChooseButton(),
            );
          }
        },
      ),
    );
  }
}
//

