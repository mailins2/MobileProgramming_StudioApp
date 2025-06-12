import 'package:flutter/material.dart';

class DetailServicePage extends StatelessWidget {
  final Map<String, dynamic> service;
  const DetailServicePage({Key? key, required this.service}) : super(key: key);

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: Color(0xFF3b051a)),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy các thuộc tính từ service
    final String spName = service["spName"] ?? "Không có tên";
    final double spPrice = service["spPrice"] != null
        ? (service["spPrice"] as num).toDouble()
        : 0;
    final int? spDuration = service["spDuration"];
    final String spDescription = service["spDescription"] ?? "";
    final int? spRawImgTime = service["spRawImgTime"];
    final int? spEditedImgTime = service["spEditedImgTime"];
    final int? spEditedReceive = service["spEditedReceive"];
    final int? spBookingDeposit = service["spBookingDeposit"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết dịch vụ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFf4f4f1))),
        centerTitle: true,
        backgroundColor: Color(0xFF3b051a),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios_outlined,size: 25,),color: Color(0xFFf1f1f4),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên dịch vụ
            Center(
              child: Text(
                spName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(thickness: 1.5),
            const SizedBox(height: 8),
            // Card chứa các thông tin chi tiết của dịch vụ
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                      child: _buildDetailItem(Icons.attach_money, "Giá", "$spPrice"),
                    ),
                    Divider(),
                    if (spDuration != null)
                      Padding(padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                        child: _buildDetailItem(
                            Icons.access_time, "Thời gian", "$spDuration phút"),
                      ),
                    Divider(),
                    if (spBookingDeposit != null)
                      Padding(padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                        child: _buildDetailItem(
                            Icons.payment, "Đặt cọc", "$spBookingDeposit"),
                      ),
                    Divider(),
                    if (spRawImgTime != null)
                      Padding(padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                        child: _buildDetailItem(
                            Icons.image, "Ảnh gốc", "$spRawImgTime giây"),
                      ),
                    Divider(),
                    if (spEditedImgTime != null)
                      Padding(padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                        child: _buildDetailItem(
                            Icons.image, "Ảnh chỉnh", "$spEditedImgTime giây"),
                      ),
                    Divider(),
                    if (spEditedReceive != null)
                      Padding(padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                        child:  _buildDetailItem(
                            Icons.photo, "Ảnh nhận chỉnh", "$spEditedReceive"),
                      ),

                    Divider(),
                    if(spDescription.isNotEmpty)
                      Padding(padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                        child:  _buildDetailItem(Icons.description, "Mô tả", spDescription),
                      ),


                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(),
            // Danh sách ảnh của dịch vụ
            if (service["images"] != null &&
                (service["images"] as List).isNotEmpty)
              Padding(padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hình ảnh",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: (service["images"] as List).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final image = service["images"][index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              image['photoURL'] ?? '',
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[300],
                                    width: 200,
                                    height: 200,
                                    child: const Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),)
          ],
        ),
      ),
    );
  }
}