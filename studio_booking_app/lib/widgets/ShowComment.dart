import 'package:flutter/material.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studio_booking_app/widgets/Post.dart';

final supabase = Supabase.instance.client;

Future<List<Map<String, dynamic>>> FetchData(int postID) async {
  final response = await supabase
      .from('Comments')
      .select('*,UserAcoount:userID(*)')
      .eq('postID',postID)
  // .order('created_at', ascending: false);
      .order('commentDate',ascending: false);

  if (response.isEmpty) {
    print('Comment is empty');
    return [];
  }

  return List<Map<String, dynamic>>.from(response);
}

Widget ShowComment (BuildContext context, int postID){

  return FutureBuilder<List<Map<String, dynamic>>>(
    future: FetchData(postID),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Text('Lỗi: ${snapshot.error}');
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Text('Không có dữ liệu');
      }

      final data = snapshot.data!;

      return Container(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 1,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(38)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Bình luận", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 50),
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {

                      final comment = data[index];
                      // final servicePackage = post['ServicePackage'] ?? {};
                      final userAccount = comment['UserAcoount'] ?? {};

                      final userAvatarRaw = userAccount['userAvatar'] ?? '';
                      final userAvatar = userAvatarRaw.trim();
                      final userName = userAccount['userFullName'] ?? 'User name';
                      // final postPhotos = post['PostPhotos'] as List<dynamic>? ?? [];

                      return Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  image: DecorationImage(
                                    image: (userAvatar != null && userAvatar.toString().isNotEmpty)
                                        ? NetworkImage(userAvatar)
                                        : AssetImage('lib/assets/images/defaultImage.png') as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Text(
                                        userName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        timeAgo(comment['commentDate']),
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.001,),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.7,
                                    margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.025),
                                    child: Text(
                                      comment['content'],
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 15,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                                ],
                              )
                            ],
                          )
                      );
                    },
                  ),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,
                      padding: EdgeInsets.only(top: 10),
                      color: white,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              image: const DecorationImage(
                                image: AssetImage("lib/assets/images/avatar.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              padding: EdgeInsets.only(left: 10,right: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey,width: 1),
                                  borderRadius: BorderRadius.circular(38)
                              ),
                              child: Center(
                                child: TextField(
                                  minLines: 1,
                                  maxLines: 14,
                                  decoration: InputDecoration(
                                    hintText: "Nhập văn bản",
                                    border: InputBorder.none,
                                  ),
                                ),
                              )
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                          IconButton(onPressed: (){}, icon: Icon(Icons.send),color: red,)
                        ],
                      ),
                    )
                )
              ],
            )
          ],
        ),
      );
    },
  );
}