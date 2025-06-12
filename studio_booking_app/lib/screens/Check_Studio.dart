import 'package:studio_booking_app/screens/Main_Studio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/userProvider.dart';
import 'Sign_Up.dart';


class CheckUserStudioPage extends StatefulWidget {
  final int userID;
  CheckUserStudioPage({required this.userID});
  @override
  _CheckUserStudioPageState createState() => _CheckUserStudioPageState();
}

class _CheckUserStudioPageState extends State<CheckUserStudioPage> {
  final supabase = Supabase.instance.client;

  Future<void> checkStudioAccess(BuildContext context, int userId) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('StudioAccount')
        .select('studioID')
        .eq('studioOwnerID', userId)
        .maybeSingle();

    if (response != null && response['studioID'] != null) {
      int studioID = response['studioID']; // Lấy giá trị studioID từ dữ liệu

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudioPage(studioId: studioID,)), // Truyền studioID
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterStuPage(userID :widget.userID )),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkStudioAccess(context, widget.userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}