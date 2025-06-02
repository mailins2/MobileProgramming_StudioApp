import 'package:flutter/material.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';
class SearchPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return Search();
  }
}

class Search extends State<StatefulWidget>{
  int selectedValue = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: red,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 30,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(40)
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 10,),
                      Icon(Icons.search,color: red,),
                      SizedBox(width: 10,),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Tìm kiếm",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                    ],
                  )
              ),
              SizedBox(width: 10,),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white, // Màu nền
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Bo góc trên
                    ),
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 1,
                        height: MediaQuery.of(context).size.height * 1,
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 1),
                        decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(38)
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Bộ lọc", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: red)),
                                SizedBox(height: 20,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Khoảng giá',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: red),)
                                  ],
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  children: [
                                    Expanded(
                                      child:Container(
                                        padding: EdgeInsets.only(left: 10,right: 10) ,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey,width: 1),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child:  TextField(
                                          textAlignVertical: TextAlignVertical.center,
                                          style: TextStyle(
                                            fontSize: 20
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '0 đ',
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(fontWeight: FontWeight.w500,color: red)
                                          ),
                                        ),

                                      )
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.1,
                                    ),
                                    Expanded(
                                        child:Container(
                                          padding: EdgeInsets.only(left: 10,right: 10) ,
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey,width: 1),
                                              borderRadius: BorderRadius.circular(10)
                                          ),
                                          child:  TextField(
                                            textAlignVertical: TextAlignVertical.center,
                                            style: TextStyle(
                                                fontSize: 20
                                            ),
                                            decoration: InputDecoration(
                                                hintText: '0 đ',
                                                border: InputBorder.none,
                                                hintStyle: TextStyle(fontWeight: FontWeight.w500,color: red)
                                            ),
                                          ),

                                        )
                                    )
                                  ],
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Phong cách',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: red),)
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
                icon: Icon(Icons.tune, color: Colors.white),
                label: Text("Lọc",style: TextStyle(fontSize: 14,color: Colors.white),),
              )
            ],
          )
        )
      ),
      body: Container(
        color: white,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
          ),
          itemBuilder: (context,index){
            return Card(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            "lib/assets/images/post1/1.jpg",
                          ),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      right: MediaQuery.of(context).size.width * 0.02,
                      top: MediaQuery.of(context).size.height * 0.01,
                      child: Opacity(
                        opacity: 0.5,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(
                              color: Colors.black,
                              width: 0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(38),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter,
                                color: Colors.white,
                                size: 11,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            );
          },
          itemCount: 20,
        ),
      ),
      floatingActionButton: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(),
        ),
        child: ElevatedButton(
          onPressed: (){
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) { // State riêng cho hộp thoại
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text(
                        'Sắp xếp theo',
                        style: TextStyle(color: red, fontWeight: FontWeight.bold),
                      ),
                      content: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text("Mới nhất", style: TextStyle(color: red, fontWeight: FontWeight.w500)),
                              leading: Radio(
                                activeColor: red,
                                value: 1,
                                groupValue: selectedValue,
                                onChanged: (int? value) {
                                  setState(() { // Cập nhật trạng thái trong hộp thoại
                                    selectedValue = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text("Gần tôi nhất", style: TextStyle(color: red)),
                              leading: Radio(
                                activeColor: red,
                                value: 2,
                                groupValue: selectedValue,
                                onChanged: (int? value) {
                                  setState(() {
                                    selectedValue = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text("Rẻ nhất", style: TextStyle(color: red)),
                              leading: Radio(
                                activeColor: red,
                                value: 3,
                                groupValue: selectedValue,
                                onChanged: (int? value) {
                                  setState(() {
                                    selectedValue = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Hủy'),
                          style: TextButton.styleFrom(
                            foregroundColor: red, // Đặt màu chữ trực tiếp
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('Áp dụng'),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: red
                          ),

                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(0),
              backgroundColor: red
          ),
          child: Icon(Icons.swap_vert,size: 24,color: Colors.white,),
        ),
      ),

    );
  }
}