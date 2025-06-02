import 'package:flutter/material.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';

Widget ShowComment (BuildContext context){
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
                itemBuilder: (BuildContext context, int index) {
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
                              image: const DecorationImage(
                                image: AssetImage("lib/assets/images/avatar.png"),
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
                                    'Studio name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto',
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text('1 giờ trước',style: TextStyle(fontSize: 10),)
                                ],
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.0005,),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.025),
                                child: Text(
                                  "EM – ĐÓA HOA RẠNG RỠ CỦA RIÊNG MÌNH\nEm đã từng dừng lại ở Memory, ở một tấm ảnh mà em yêu thích, từng lướt qua một bộ ảnh mà mình tưởng tượng mình là nhân vật chính...\nVà có lẽ – đã đến lúc em thực sự bước vào khung hình dành riêng cho mình.",
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12,
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
                itemCount: 10,
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
}