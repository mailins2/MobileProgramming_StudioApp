import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailDvDemo extends StatefulWidget {
  final int spID;

  const DetailDvDemo({Key? key, required this.spID}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DetailDvState();
  }
}

class DetailDvState extends State<DetailDvDemo> {
  final List<String> imageUrls = [
    'lib/assets/images/anh.jpg',
    'lib/assets/images/anh1.jpg',
    'lib/assets/images/anh2.jpg',
    'lib/assets/images/anh3.jpg',
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final double slideshowHeight = screenHeight * 0.4;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 244, 241),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 244, 244, 241),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: slideshowHeight,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  margin: const EdgeInsets.all(0.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: imageUrls.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.asset(
                          imageUrls[index],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(imageUrls.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: _currentPage == index ? 12.0 : 8.0,
                        height: _currentPage == index ? 12.0 : 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color.fromARGB(255, 59, 5, 16)
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
                buildInfoRow("Dịch vụ", "Chụp concept cá nhân theo sở thích lựa chọn", 40),
                buildInfoRow("Giá", "1.000.000đ", 75),
                buildInfoRow("Mô tả",
                    "Chụp ảnh cá nhân, Lorem ipsum dolor sit amet, consectetur adipiscing elit.", 55),
                Container(
                  padding: const EdgeInsets.only(top: 35),
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Thông tin gói chụp",
                        style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10, left: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Thông tin chi tiết gói chụp sẽ hiển thị ở đây.',
                    style: const TextStyle(fontSize: 19),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            print("Đặt lịch với spID: ${widget.spID}");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 59, 5, 16),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Đặt lịch",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(String title, String content, double spacing) {
    return Container(
      padding: const EdgeInsets.only(top: 35),
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, color: Colors.grey[400]),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(fontSize: 18),
            ),
          )
        ],
      ),
    );
  }
}
