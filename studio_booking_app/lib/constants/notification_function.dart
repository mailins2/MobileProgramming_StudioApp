import 'package:studio_booking_app/models/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Notification NotiTemplate(int userType, String bookingStatus, int bookID, [int? cancelType]) {

  Notification noti = Notification();
  switch (userType) {
    case 0:
      switch(bookingStatus){
        case 'Chưa xác nhận': // user
          noti.NotiType = 'Đặt lịch';
          noti.NotiTitle = 'Đã đặt lịch hẹn';
          noti.NotiContent = 'Bạn đã đặt dịch vụ “Chụp ảnh chân dung” của '
              '“studio Harmony”. Lịch hẹn đang chờ xác nhận.';
          break;
        case 'Đã hủy':
          noti.NotiType = 'Đặt lịch';
          noti.NotiTitle = 'Đã hủy lịch hẹn';
          if(cancelType == 0)
            {
              noti.NotiContent = 'Yêu cầu đặt lịch của bạn với “tên studio ” đã hủy thành công.';
            }
          else
            {
              noti.NotiContent = 'Lịch hẹn của bạn với studio Harmony không được chấp nhận. Vui lòng chọn dịch vụ khác hoặc studio khác!';
            }
          break;
        case 'Chưa thanh toán':
          noti.NotiType = 'Đặt lịch';
          noti.NotiTitle = 'Lịch hẹn đã được chấp nhận';
          noti.NotiContent = 'Lịch hẹn của bạn với studio Harmony đã được chấp nhận. Bạn cần thanh toán tiền cọc trong vòng 24 giờ để xác nhận lịch hẹn.\n'
              'Lưu ý: Khoản cọc sẽ không được hoàn trả nếu bạn hủy lịch.';
          break;
        case 'Đã xác nhận':
          noti.NotiType = 'Đặt lịch';
          noti.NotiTitle = 'Lịch hẹn đã được xác nhận';
          noti.NotiContent = 'Lịch hẹn của bạn với “studio Harmony” đã được xác nhận.';
          break;
      }
    case 1:
      switch(bookingStatus){
        case 'Chưa xác nhận': // stuido
          noti.NotiType = 'Đặt lịch';
          noti.NotiTitle = 'Yêu cầu đặt lịch';
          noti.NotiContent = 'Studio thân mến, hiện có một khách hàng vừa đặt dịch vụ tại studio.'
              ' Vui lòng xác nhận sớm để đảm bảo trải nghiệm tốt nhất và tránh trường hợp khách thay đổi ý định.';
          break;
        case 'Đã xác nhận':
          noti.NotiType = 'Đặt lịch';
          noti.NotiTitle = 'Lịch hẹn đã được xác nhận';
          noti.NotiContent = 'Khách hàng “tên user” đã thanh toán khoản cọc cho lịch hẹn BK”mã bookID”.';
          break;

      }

  }
  return noti;
}
void notification_insert_user(Notification noti, int userId) async {
  final notiMessage = await Supabase.instance.client
      .from('UserNotification')
      .insert({
    "CreatedDate": noti.CreateDate is DateTime
        ? (noti.CreateDate as DateTime).toIso8601String()
        : noti.CreateDate, // an toàn nếu đã là chuỗi
    "NotiType": noti.NotiType,
    "NotiTitle": noti.NotiTitle,
    "NotiContent": noti.NotiContent,
    "userID": userId,
  }).select();
  print('📨 UserNotification inserted: $notiMessage');
}




void notification_insert_studio(Notification noti, int studioId) async {
  final notiMessage = await Supabase.instance.client
      .from('StuNotification')
      .insert({
    "CreatedDate": noti.CreateDate is DateTime
        ? (noti.CreateDate as DateTime).toIso8601String()
        : noti.CreateDate,
    "NotiType": noti.NotiType,
    "NotiTitle": noti.NotiTitle,
    "NotiContent": noti.NotiContent,
    "studioID": studioId,
  }).select();
  print('📨 StuNotification inserted: $notiMessage');
}




void listenToRealtimeBooking(int currentUserId) {
  final supabase = Supabase.instance.client;

  supabase.channel('booking_channel')
      .onPostgresChanges(
    event: PostgresChangeEvent.insert,
    schema: 'public',
    table: 'Booking',
    callback: (payload) async {
      final booking = payload.newRecord;

      final int? userID = booking['userID'];
      final int? spID = booking['spID'];
      final String? status = booking['bookingStatus'];
      final int? bookingID = booking['bookingID'];
      final int? cancelType = booking['cancelType']; // optional

      if (userID == null || spID == null || status == null || bookingID == null) {
        print("⚠️ Dữ liệu booking thiếu thông tin: $booking");
        return;
      }

      // 🔄 Truy ngược studioID từ spID (truy vấn ServicePackage)
      final studioRes = await supabase
          .from('ServicePackage')
          .select('studioID')
          .eq('spID', spID)
          .maybeSingle();

      final int? studioID = studioRes?['studioID'];
      if (studioID == null) {
        print("❌ Không tìm thấy studioID từ spID=$spID");
        return;
      }

      // ✅ Gửi thông báo cho user
      Notification userNoti = NotiTemplate(0, status, bookingID, cancelType);
      userNoti.CreateDate = DateTime.now();
      notification_insert_user(userNoti, userID);

      // ✅ Gửi thông báo cho studio
      Notification studioNoti = NotiTemplate(1, status, bookingID, cancelType);
      studioNoti.CreateDate = DateTime.now();
      notification_insert_studio(studioNoti, studioID);
    },
  )
      .subscribe();
}

