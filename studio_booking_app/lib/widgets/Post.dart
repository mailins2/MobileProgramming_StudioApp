import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';
import 'package:studio_booking_app/widgets/ShowComment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide PostgrestResponse;
import 'package:supabase/supabase.dart';

final supabase = Supabase.instance.client;

Future<List<Map<String, dynamic>>> FetchData() async {
  final response = await supabase
      .from('Post')
      .select('*, ServicePackage:spID(*, StudioAccount:studioID(*)), PostPhotos(*)')
      .order('createdDate', ascending: false);

  if (response.isEmpty) {
    print('Post is empty');
    return [];
  }

  return List<Map<String, dynamic>>.from(response);
}

Future<int> fetchCommentCount(int postID) async {
  final response = await supabase
      .from('Comments')
      .select('commentID')
      .eq('postID', postID);

  if (response != null && response is List) {
    return response.length;
  }
  return 0;
}

String formatCurrency(dynamic price) {
  if (price == null) return '0đ';
  final number = double.tryParse(price.toString()) ?? 0;
  return '${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ';
}

String timeAgo(String? createdDateStr) {
  if (createdDateStr == null || createdDateStr.isEmpty) return '';

  DateTime createdDate = DateTime.parse(createdDateStr);
  final now = DateTime.now();
  final diff = now.difference(createdDate);

  if (diff.inSeconds < 60) {
    return '${diff.inSeconds} giây trước';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes} phút trước';
  } else if (diff.inHours < 24) {
    return '${diff.inHours} giờ trước';
  } else if (diff.inDays < 365) {
    return '${diff.inDays} ngày trước';
  } else {
    final years = (diff.inDays / 365).floor();
    return '$years năm trước';
  }
}

Widget Post(BuildContext context, int index, int itemcount) {
  final PageController _pageController = PageController();
  final Map<int, bool> likedStatusMap = {};
  final Map<int, bool> expandedContentMap = {};

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
          itemCount: itemcount,
          itemBuilder: (context, index) {
            final post = data[index];
            final servicePackage = post['ServicePackage'] ?? {};
            final studioAccount = servicePackage['StudioAccount'] ?? {};

            final studioAvatarRaw = studioAccount['studioAvatar'] ?? '';
            final studioAvatar = studioAvatarRaw.trim();
            final studioName = studioAccount['studioName'] ?? 'Studio name';
            final postPhotos = post['PostPhotos'] as List<dynamic>? ?? [];

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
                        overflow: TextOverflow.ellipsis,
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
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: postPhotos.length,
                            itemBuilder: (context, i) {
                              final rawURL = postPhotos[i]['photoURL'];
                              final photoURL = rawURL != null ? rawURL.toString().trim() : null;
                              return Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(9.5)),
                                      image: DecorationImage(
                                        image: photoURL != null && photoURL.isNotEmpty
                                            ? NetworkImage(photoURL)
                                            : AssetImage('lib/assets/images/defaultImage.png') as ImageProvider,
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
                                              children: [
                                                Icon(Icons.filter, color: Colors.white, size: 11),
                                                SizedBox(width: 5),
                                                Text('${i + 1}/${postPhotos.length}', style: TextStyle(fontSize: 9, color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
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
                                        '${servicePackage['spName'] ?? 'Gói chụp'} - ${formatCurrency(servicePackage['spPrice'])}',
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
                          StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              final postID = post['postID'];
                              int likes = post['likes'] ?? 0;
                              bool isLiked = likedStatusMap[postID] ?? false;

                              return Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final newLikes = isLiked ? likes - 1 : likes + 1;
                                      final res = await supabase
                                          .from('Post')
                                          .update({'likes': newLikes})
                                          .eq('postID', postID)
                                          .select();

                                      if (res.isNotEmpty) {
                                        setState(() {
                                          likedStatusMap[postID] = !isLiked;
                                          post['likes'] = newLikes;
                                        });
                                      }
                                    },
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_outline,
                                      color: red,
                                      size: 26,
                                    ),
                                  ),
                                  Text(
                                    '${post['likes']}',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return ShowComment(context, post['postID']);
                                },
                              );
                            },
                            icon: Icon(FontAwesomeIcons.comment, color: red, size: 22),
                          ),
                          FutureBuilder<int>(
                            future: fetchCommentCount(post['postID']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text('', style: TextStyle(fontSize: 14));
                              } else if (snapshot.hasError) {
                                return Text('0', style: TextStyle(fontSize: 14));
                              }
                              return Text(
                                '${snapshot.data}',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
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
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            final postID = post['postID'];
                            final fullContent = post['content'] ?? '';
                            final isExpanded = expandedContentMap[postID] ?? false;
                            final shouldTruncate = fullContent.length > 150;

                            String displayedContent = fullContent;
                            if (shouldTruncate && !isExpanded) {
                              displayedContent = fullContent.substring(0, 150).trim();
                            }

                            return RichText(
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: displayedContent,
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (shouldTruncate)
                                    TextSpan(
                                      text: isExpanded ? ' Thu gọn' : '...Xem thêm',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 12,
                                        color: red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          setState(() {
                                            expandedContentMap[postID] = !isExpanded;
                                          });
                                        },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 4),
                        Text(
                          post['spTag'] != null && post['spTag'].toString().isNotEmpty
                              ? '#${post['spTag']}'
                              : '',
                          style: TextStyle(
                            color: red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Text(
                        timeAgo(post['createdDate']),
                        style: TextStyle(fontSize: 10),
                      ),
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
