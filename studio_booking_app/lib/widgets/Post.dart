import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';
import 'package:studio_booking_app/widgets/ShowComment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<List<Map<String, dynamic>>> FetchData() async {
  final response = await supabase
      .from('Post')
      .select('*, ServicePackage:spID(*, StudioAccount:studioID(*))');

  if (response.isEmpty) {
    print('Post is empty');
    return [];
  }

  return List<Map<String, dynamic>>.from(response);
}

Widget Post(BuildContext context, int index) {
  final PageController _pageController = PageController();

  return FutureBuilder<List<Map<String, dynamic>>>(
    future: FetchData(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Text('Lỗi: ${snapshot.error}');
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Text('Không có dữ liệu');
      }

      final data = snapshot.data!;

      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final post = data[index];
            final servicePackage = post['ServicePackage'] ?? {};
            final studioAccount = servicePackage['StudioAccount'] ?? {};

            final studioAvatarRaw = studioAccount['studioAvatar'] ?? '';
            final studioAvatar = studioAvatarRaw.trim();
            final studioName = studioAccount['studioName'] ?? 'Studio name';

            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          image: DecorationImage(
                            image: (studioAvatar != null && studioAvatar.toString().isNotEmpty)
                                ? NetworkImage(studioAvatar)
                                : AssetImage('lib/assets/images/defaultImage.png') as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        studioName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.4,
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: red, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: PageView(
                            controller: _pageController,
                            children: [
                              for (int i = 0; i < 9; i++)
                                Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(9.5),
                                        ),
                                        image: DecorationImage(
                                          image: AssetImage(
                                            "lib/assets/images/post1/${i + 1}.jpg",
                                          ),
                                          fit: BoxFit.cover,
                                          alignment: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: MediaQuery.of(context).size.width * 0.02,
                                      top: MediaQuery.of(context).size.height * 0.01,
                                      child: Row(
                                        children: [
                                          Opacity(
                                            opacity: 0.5,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.all(Radius.circular(38)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.filter,
                                                    color: Colors.white,
                                                    size: 11,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    '${i + 1}/9',
                                                    style: TextStyle(fontSize: 9, color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.02,
                          bottom: MediaQuery.of(context).size.height * 0.02,
                          child: Row(
                            children: [
                              Opacity(
                                opacity: 0.8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(38)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.photo_camera, color: Colors.black, size: 15),
                                      SizedBox(width: 5),
                                      Text(
                                        'Concept chân dung - 1,500,000đ',
                                        style: TextStyle(fontSize: 12, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: MediaQuery.of(context).size.width * 0.025),
                          IconButton(onPressed: () {}, icon: Icon(Icons.favorite_outline, color: red, size: 26)),
                          Text('123', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return ShowComment(context);
                                },
                              );
                            },
                            icon: Icon(FontAwesomeIcons.comment, color: red, size: 22),
                          ),
                          Text('123', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text('Đặt dịch vụ', style: TextStyle(color: Colors.white, fontSize: 12)),
                            style: TextButton.styleFrom(
                              backgroundColor: red,
                              minimumSize: Size(50, 30),
                            ),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Text(
                        studioName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', fontSize: 15),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Text(
                          "EM – ĐÓA HOA RẠNG RỠ CỦA RIÊNG MÌNH\nEm đã từng dừng lại ở Memory, ở một tấm ảnh mà em yêu thích, từng lướt qua một bộ ảnh mà mình tưởng tượng mình là nhân vật chính...\nVà có lẽ – đã đến lúc em thực sự bước vào khung hình dành riêng cho mình.",
                          style: TextStyle(fontFamily: 'Roboto', fontSize: 12),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.justify,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Text('1 giờ trước', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
