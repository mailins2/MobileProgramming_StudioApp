import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';

class BookingScreen extends StatefulWidget {
  final int userId;
  final int spId;
  const BookingScreen({super.key, required this.userId, required this.spId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final supabase = Supabase.instance.client;

  int userId = 0;
  int spId = 0;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController addressController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool isAtStudio = true;
  bool isLoading = false;

  String? studioAddress;
  late Future<Map<String, dynamic>?> studioFuture;
  late Future<Map<String, dynamic>?> servicePackageFuture;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    spId = widget.spId;
    studioFuture = getStudioByServicePackageId(spId);
    servicePackageFuture = getServicePackage(spId);
  }

  Future<Map<String, dynamic>?> getStudioByServicePackageId(int spId) async {
    // 1. Lấy studioID từ ServicePackage
    final service = await supabase
        .from('ServicePackage')
        .select('studioID')
        .eq('spID', spId)
        .maybeSingle();

    final studioID = service?['studioID'];
    if (studioID == null) return null;

    // 2. Truy vấn StudioAccount riêng
    final studio = await supabase
        .from('StudioAccount')
        .select('studioAddress, studioAvatar, studioName, studioAccountName')
        .eq('studioID', studioID)
        .maybeSingle();

    studioAddress = studio?['studioAddress'];
    return studio; // giả lập cùng cấu trúc để không phải đổi UI
  }


  Future<Map<String, dynamic>?> getServicePackage(int spId) async {
    final response = await supabase
        .from('ServicePackage')
        .select('*')
        .eq('spID', spId)
        .maybeSingle();
    return response;
  }

  Future<void> insertBooking() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      if (selectedDate == null || selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn ngày và giờ')),
        );
        return;
      }

      final DateTime fullDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      if (fullDateTime.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể đặt lịch trong quá khứ')),
        );
        return;
      }

      String? finalAddress;
      if (isAtStudio) {
        if (studioAddress == null || studioAddress!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không tìm thấy địa chỉ studio')),
          );
          return;
        }
        finalAddress = studioAddress!;
      } else {
        if (addressController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vui lòng nhập địa chỉ đặt lịch')),
          );
          return;
        }
        finalAddress = addressController.text.trim();
      }

      final existingBooking = await supabase
          .from('Booking')
          .select()
          .eq('userID', userId)
          .gte('bookingTime', fullDateTime.toIso8601String())
          .lt('bookingTime', fullDateTime.add(Duration(hours: 1)).toIso8601String())
          .maybeSingle();

      if (existingBooking != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bạn đã có lịch trong khoảng thời gian này')),
        );
        return;
      }

      await supabase.from('Booking').insert({
        'userID': userId,
        'spID': spId,
        'bookingTime': fullDateTime.toIso8601String(),
        'bookingAddress': finalAddress,
        'bookingNotes': noteController.text.trim(),
        'bookingStatus': 'Chưa xác nhận',
        'createdDate': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đặt lịch thành công')),
      );

      await Future.delayed(Duration(milliseconds: 300));
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi đặt lịch: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: red,
        centerTitle: true,
        title: Text(
          'Đặt lịch',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: white,
          ),
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([studioFuture, servicePackageFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Không thể tải dữ liệu.'));
          }

          final studioData = snapshot.data![0] as Map<String, dynamic>?;
          final serviceData = snapshot.data![1] as Map<String, dynamic>?;

          final spName = serviceData?['spName'] ?? '---';
          final spDeposit = serviceData?['spBookingDeposit'] ?? 0;

          final studioAccount = studioData?['studioAccountName']?.toString() ?? 'Studio';
          final studioName = studioData?['studioName']?.toString() ?? 'Studio';
          final Avatar =studioData?['studioAvatar']?.toString() ?? '';


          final formattedPrice = NumberFormat('#,###').format(serviceData?['spPrice'] ?? 0);
          final formattedspDeposit = NumberFormat('#,###').format(spDeposit);
          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(color: grey),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: red, width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'STUDIO',
                          style: TextStyle(color: black, fontSize: 15),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                  image:
                                  (Avatar != null &&
                                      Avatar.toString().isNotEmpty)
                                      ? NetworkImage(Avatar)
                                      : AssetImage(
                                    'lib/assets/images/defaultImage.png',
                                  )
                                  as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studioName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(studioAccount),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: red, width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THỜI GIAN, ĐỊA ĐIỂM',
                          style: TextStyle(color: black, fontSize: 15),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: 170,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  final now = DateTime.now(); // GỌI 1 LẦN DUY NHẤT

                                  DateTime tempPickedDate = selectedDate ?? now;

                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext builder) {
                                      return Localizations.override(
                                        context: context,
                                        locale: const Locale('vi'),
                                        child: Container(
                                          height: 250,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: CupertinoDatePicker(
                                                  mode: CupertinoDatePickerMode.date,
                                                  minimumDate: now,              // Dùng đúng biến now
                                                  initialDateTime: tempPickedDate.isBefore(now) ? now : tempPickedDate, // So sánh trước khi gán
                                                  onDateTimeChanged: (DateTime newDate) {
                                                    tempPickedDate = newDate;
                                                  },
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    selectedDate = tempPickedDate;
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Xong'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },

                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0, right: 0), // Giảm trái, giữ phải
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedDate != null
                                            ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                                            : 'Chọn ngày',
                                        style: TextStyle(
                                          color: selectedDate != null ? Colors.black : Colors.grey,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        color: Colors.grey,
                                        size: 23,
                                      ),
                                    ],
                                  ),
                                ),

                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            SizedBox(
                              width: 170,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (BuildContext builder) {
                                      Duration tempDuration = Duration(
                                        hours: selectedTime?.hour ?? 0,
                                        minutes: selectedTime?.minute ?? 0,
                                      );
                                      return Container(
                                        height: 250,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: CupertinoTimerPicker(
                                                mode: CupertinoTimerPickerMode.hm,
                                                initialTimerDuration: tempDuration,
                                                backgroundColor: Colors.white,
                                                onTimerDurationChanged: (Duration newTime) {
                                                  tempDuration = newTime;
                                                },
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedTime = TimeOfDay(
                                                    hour: tempDuration.inHours,
                                                    minute: tempDuration.inMinutes.remainder(60),
                                                  );
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: Text('Xong'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedTime != null
                                          ? selectedTime!.format(context)
                                          : 'Thời gian',
                                      style: TextStyle(
                                        color: selectedTime != null ? Colors.black : Colors.grey,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.grey,
                                      size: 23,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: addressController,
                          enabled: !isAtStudio, // disable nếu là tại studio
                          decoration: InputDecoration(
                            hintText: 'Địa chỉ đặt lịch',
                            prefixIcon: Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                        SizedBox(height: 12),
                        CheckboxListTile(
                          value: isAtStudio,
                          onChanged: (value) {
                            setState(() {
                              isAtStudio = value ?? true;

                              // Nếu chọn "Tại studio" thì xóa địa chỉ nhập tay (nếu có)
                              if (isAtStudio) {
                                addressController.clear();
                              }
                            });
                          },
                          title: Text('Tại studio : $studioAddress'),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: red,
                          contentPadding: EdgeInsets.only(left: 0),
                        ),


                        SizedBox(height: 12),
                        TextField(
                          controller: noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Ghi chú',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              // màu khi chưa focus
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 2,
                              ),
                              // màu khi focus
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: red, width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'GÓI CHỤP',
                              style: TextStyle(color: black, fontSize: 15),
                            ),
                          ],
                        ),
                        Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  spName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text('Phí cọc dịch vụ :'),
                              ],
                            ),
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.end,
                              children: [
                                Text('$formattedPriceđ'),
                                Text(
                                  '$formattedspDepositđ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height:
                          MediaQuery.of(context).size.height * 0.005,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng thanh toán trên app',
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(
                              '$formattedspDepositđ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              insertBooking();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: red),
                            child: Text(
                              'Đặt lịch',
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),

                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

