import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ThongBaoArtistDemo extends StatefulWidget {
  final int currentUserId;

  const ThongBaoArtistDemo({super.key, required this.currentUserId});

  @override
  State<ThongBaoArtistDemo> createState() => _ThongBaoArtistState();
}

class _ThongBaoArtistState extends State<ThongBaoArtistDemo> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;

  final _userNotiController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _studioNotiController = StreamController<List<Map<String, dynamic>>>.broadcast();

  List<Map<String, dynamic>> _userNotiData = [];
  List<Map<String, dynamic>> _studioNotiData = [];

  late final RealtimeChannel _userNotiChannel;
  late final RealtimeChannel _studioNotiChannel;

  @override
  void initState() {
    super.initState();
    print('🚀 initState: Bắt đầu setup notification listener...');
    _tabController = TabController(length: 2, vsync: this);
    _setupUserNotiListener();
    _setupStudioNotiListener();
  }

  Future<void> _setupUserNotiListener() async {
    try {
      final data = await _supabase
          .from('UserNotification')
          .select('*')
          .eq('userID', widget.currentUserId)
          .order('CreatedDate', ascending: false);
      _userNotiData = List<Map<String, dynamic>>.from(data);
      print('✅ [UserNotification] Đã tải danh sách ${_userNotiData.length} thông báo.');
      if (!_userNotiController.isClosed) _userNotiController.add(_userNotiData);

      _userNotiChannel = _supabase.channel('public:UserNotification')
        ..onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'UserNotification',
          callback: (payload) {
            print('👤 [REALTIME] New payload received on UserNotification');
            debugPrint(jsonEncode(payload.newRecord), wrapWidth: 1024);
            final newItem = payload.newRecord;
            if (newItem['userID'] == widget.currentUserId) {
              _userNotiData.insert(0, newItem);
              if (!_userNotiController.isClosed) {
                _userNotiController.add(_userNotiData);
                print('📡 [UserNotiController] Đã cập nhật danh sách: ${_userNotiData.length} thông báo.');
              }
              print('👤 User Notification: ${newItem['NotiTitle']}');
            }
          },
        )
        ..subscribe();
    } catch (e) {
      print('❌ [UserNotification] Lỗi khi thiết lập listener: $e');
    }
  }

  Future<void> _setupStudioNotiListener() async {
    try {
      final studioData = await _supabase
          .from('StudioAccount')
          .select('studioID')
          .eq('studioOwnerID', widget.currentUserId)
          .maybeSingle();

      if (studioData == null) {
        print('❌ Không tìm thấy studio cho userID: ${widget.currentUserId}');
        // Thay vì return, add list rỗng vào stream để UI không đợi nữa
        if (!_studioNotiController.isClosed) {
          _studioNotiController.add([]);
        }
        return;
      }

      final studioID = studioData['studioID'];
      print('✅ Studio ID: $studioID');

      final data = await _supabase
          .from('StuNotification')
          .select('*')
          .eq('studioID', studioID)
          .order('CreatedDate', ascending: false);

      _studioNotiData = List<Map<String, dynamic>>.from(data);
      print('✅ [StuNotification] Đã tải danh sách ${_studioNotiData.length} thông báo.');
      if (!_studioNotiController.isClosed) _studioNotiController.add(_studioNotiData);

      _studioNotiChannel = _supabase.channel('public:StuNotification')
        ..onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'StuNotification',
          callback: (payload) {
            print('📥 [REALTIME] New payload received on StuNotification');
            debugPrint(jsonEncode(payload.newRecord), wrapWidth: 1024);
            final newItem = payload.newRecord;
            if (newItem['studioID'] == studioID) {
              _studioNotiData.insert(0, newItem);
              if (!_studioNotiController.isClosed) {
                _studioNotiController.add(_studioNotiData);
                print('📡 [StudioNotiController] Đã cập nhật danh sách: ${_studioNotiData.length} thông báo.');
              }
              print('🎨 Studio Notification: ${newItem['NotiTitle']}');
            }
          },
        )
        ..subscribe();
    } catch (e) {
      print('❌ [StuNotification] Lỗi khi thiết lập listener: $e');
      if (!_studioNotiController.isClosed) {
        _studioNotiController.add([]);
      }
    }
  }


  @override
  void dispose() {
    print('🧹 dispose: Cleaning up channels and controllers...');
    _tabController.dispose();
    _userNotiController.close();
    _studioNotiController.close();
    _userNotiChannel.unsubscribe();
    _studioNotiChannel.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4F1),
        title: const Text(
          "Thông Báo",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _testInsertNoti,
            tooltip: 'Thêm thông báo test',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.black,
            labelColor: const Color(0xFF3B0510),
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            tabs: const [
              Tab(text: 'Thông báo của tôi'),
              Tab(text: 'Cập nhật của artist'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationTab(_userNotiController.stream),
                _buildNotificationTab(_studioNotiController.stream),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTab(Stream<List<Map<String, dynamic>>> stream) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('🔄 [StreamBuilder] Đang chờ dữ liệu...');
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('ℹ️ [StreamBuilder] Không có dữ liệu hoặc danh sách trống.');
          return const Center(child: Text('Không có thông báo nào.'));
        }

        print('📋 [StreamBuilder] Đã nhận ${snapshot.data!.length} thông báo.');

        final data = snapshot.data!;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return _buildNotificationItem(
              type: item['NotiType'] ?? 'Không rõ',
              title: item['NotiTitle'] ?? 'Không có tiêu đề',
              content: item['NotiContent'] ?? '',
              date: item['CreatedDate'],
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required String type,
    required String title,
    required String content,
    required dynamic date,
  }) {
    final formattedDate = _formatDateOnly(date);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(20),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notifications_active, size: 28, color: Color(0xFF3B0510)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        type,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• $formattedDate',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.more_vert, size: 20),
        ],
      ),
    );
  }

  String _formatDateOnly(dynamic date) {
    try {
      final parsedDate = DateTime.parse(date.toString()).toLocal();
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (_) {
      return '';
    }
  }

  void _testInsertNoti() async {
    final now = DateTime.now().toIso8601String();

    try {
      await _supabase.from('UserNotification').insert({
        'NotiType': 'Test',
        'NotiTitle': 'Thông báo test cho user',
        'NotiContent': 'Nội dung kiểm tra realtime cho user ${widget.currentUserId}',
        'userID': widget.currentUserId,
        'CreatedDate': now,
      });
      print('✅ Inserted user notification at $now');
    } catch (e) {
      print('❌ Failed to insert user notification: $e');
    }

    try {
      final studioData = await _supabase
          .from('StudioAccount')
          .select('studioID')
          .eq('studioOwnerID', widget.currentUserId)
          .maybeSingle();

      if (studioData != null) {
        final studioID = studioData['studioID'];
        await _supabase.from('StuNotification').insert({
          'NotiType': 'Test',
          'NotiTitle': 'Thông báo test cho artist',
          'NotiContent': 'Nội dung kiểm tra realtime cho studio $studioID',
          'studioID': studioID,
          'CreatedDate': now,
        });
        print('🧪 Inserted studio notification at $now');
      } else {
        print('❌ Không tìm thấy studioID để thêm thông báo.');
      }
    } catch (e) {
      print('❌ Failed to insert studio notification: $e');
    }
  }
}
