import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';
import 'package:studio_booking_app/constants/text-font.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studio_booking_app/screens/signIn.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool showPassword = false;

  Future<void> _validateAndSubmit() async {
    final email = emailController.text.trim();
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin', Colors.red);
      return;
    }

    final passwordPattern = RegExp(r'^\S{10,20}$');

    if (!passwordPattern.hasMatch(newPassword)) {
      _showSnackBar('Mật khẩu mới phải từ 10–20 ký tự và không chứa khoảng trắng', Colors.red);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('Mật khẩu không khớp', Colors.red);
      return;
    }

    try {
      final user = await Supabase.instance.client
          .from('UserAcoount')
          .select('userId')
          .eq('userEmail', email)
          .maybeSingle();

      if (user == null) {
        _showSnackBar('Email không tồn tại trong hệ thống', Colors.red);
        return;
      }

      final updateResponse = await Supabase.instance.client
          .from('UserAcoount')
          .update({'userPassword': newPassword})
          .eq('userEmail', email);

      _showSnackBar('Đổi mật khẩu thành công!', Colors.green);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignIn()),
            (route) => false,
      );
    } catch (e) {
      _showSnackBar('Đã xảy ra lỗi. Vui lòng thử lại.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          'Booking Studio',
          style: TextStyle(
            fontFamily: logo_font,
            fontWeight: logo_fontweight,
            fontSize: 25,
            color: white,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Text(
                'Đặt lại mật khẩu mới',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: red,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              /// Email field
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: emailController,
                  maxLength: 50,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Nhập email đã đăng ký",
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              /// New password field
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: newPasswordController,
                  obscureText: !showPassword,
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: "Nhập mật khẩu mới",
                    border: InputBorder.none,
                    counterText: '',
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                        color: grey,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              /// Confirm password field
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: confirmPasswordController,
                  obscureText: !showPassword,
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: "Nhập lại mật khẩu mới",
                    border: InputBorder.none,
                    counterText: '',
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                        color: grey,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),

              /// Submit button
              ElevatedButton(
                onPressed: _validateAndSubmit,
                child: Text('Đặt lại'),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 20),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                  minimumSize: Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: red,
                  foregroundColor: white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
