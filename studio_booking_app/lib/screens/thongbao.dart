

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ThongBaoDemo extends StatefulWidget {
  final int currentUserId;

  ThongBaoDemo({required this.currentUserId});

  @override
  State<StatefulWidget> createState() => ThongBaoState();
}

// Hàm định dạng ngày
String formatDateOnly(String isoDateString) {
  try {
    final dt = DateTime.parse(isoDateString).toLocal();
    return DateFormat('dd/MM/yyyy').format(dt);
  } catch (_) {
    return '';
  }
}

class ThongBaoState extends State<ThongBaoDemo> {
  final _supabase = Supabase.instance.client;
  late StreamController<List<Map<String, dynamic>>> _controller;
  late RealtimeChannel _subscription;
  List<Map<String, dynamic>> _currentData = [];
  @override
  void initState() {
    super.initState();
    _controller = StreamController<List<Map<String, dynamic>>>();
    _fetchAndSubscribe();
  }

  // void _fetchAndSubscribe() async {
  //   // B1: Lấy dữ liệu ban đầu của user hiện tại
  //   final initialData = await _supabase
  //       .from('UserNotification')
  //       .select('*')
  //       .eq('userID', widget.currentUserId) // lọc theo user
  //       .order('CreatedDate', ascending: false);
  //
  //   _controller.add(List<Map<String, dynamic>>.from(initialData));
  //
  //   // B2: Lắng nghe realtime thêm bản ghi mới
  //   _subscription = _supabase.channel('public:UserNotification')
  //     ..onPostgresChanges(
  //       event: PostgresChangeEvent.insert,
  //       schema: 'public',
  //       table: 'UserNotification',
  //       callback: (payload) async {
  //         final newItem = payload.newRecord;
  //
  //         // Chỉ thêm nếu newItem thuộc về currentUserId
  //         if (newItem['userID'] == widget.currentUserId) {
  //           final currentData = List<Map<String, dynamic>>.from(
  //             _controller.hasListener ? await _controller.stream.first : [],
  //           );
  //           currentData.insert(0, newItem);
  //           _controller.add(currentData);
  //         }
  //       },
  //     )
  //     ..subscribe();
  // }
  void _fetchAndSubscribe() async {
    // B1: Lấy dữ liệu ban đầu
    final initialData = await _supabase
        .from('UserNotification')
        .select('*')
        .eq('userID', widget.currentUserId)
        .order('CreatedDate', ascending: false);

    _currentData = List<Map<String, dynamic>>.from(initialData);
    _controller.add(_currentData);

    // B2: Lắng nghe realtime thêm bản ghi mới
    _subscription = _supabase.channel('public:UserNotification')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'UserNotification',
        callback: (payload) async {
          final newItem = payload.newRecord;

          if (newItem['userID'] == widget.currentUserId) {
            _currentData.insert(0, newItem); // cập nhật dữ liệu
            _controller.add(_currentData);
            print('📥 Thêm mới: ${newItem['NotiTitle']}');
          }
        },
      )
      ..subscribe();
  }

  @override
  void dispose() {
    _subscription.unsubscribe();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4F1),
        title: const Text(
          "Thông Báo",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        color: const Color(0xFFF4F4F1),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _controller.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;
            if (data.isEmpty) {
              return const Center(child: Text('Không có thông báo nào.'));
            }

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return getTemplateNoti(
                  type: item['NotiType'] ?? '',
                  title: item['NotiTitle'] ?? '',
                  content: item['NotiContent'] ?? '',
                  formattedDate: formatDateOnly(item['CreatedDate'] ?? ''),
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Supabase.instance.client.from('UserNotification').insert({
            'NotiType': 'Test',
            'NotiTitle': 'Thông báo realtime',
            'NotiContent': 'Thông báo thử cho user ${widget.currentUserId}',
            'userID': widget.currentUserId,
            'CreatedDate': DateTime.now().toIso8601String(),
          });
        },
        child: Icon(Icons.add),
      ),

    );
  }

  Widget getTemplateNoti({
    required String type,
    required String title,
    required String content,
    required String formattedDate,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
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
                    Text(
                      type,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• $formattedDate',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    height: 1.5,
                  ),
                ),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 19,
                    height: 1.5,
                  ),
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
}

