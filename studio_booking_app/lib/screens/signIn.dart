import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';
import 'package:studio_booking_app/constants/text-font.dart';
import 'package:studio_booking_app/screens/signUp.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studio_booking_app/screens/index.dart';
import 'package:provider/provider.dart';
import 'package:studio_booking_app/providers/userProvider.dart';
import 'package:studio_booking_app/models/userModel.dart';
import 'package:studio_booking_app/screens/forgotPassword.dart';

final supabase = Supabase.instance.client;

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;

  Future<void> _signIn() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Vui lòng nhập đầy đủ thông tin'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final response = await supabase
        .from('UserAcoount')
        .select()
        .eq('userPhoneNumber', phone)
        .eq('userPassword', password)
        .maybeSingle();

    if (response != null) {
      final userData = UserModel.fromMap(response); // response từ Supabase
      Provider.of<UserProvider>(context, listen: false).setUser(userData);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Default()),
            (route) => false,
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sai số điện thoại hoặc mật khẩu'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: red,
        title: Center(
          child: Text(
            'Booking Studio',
            style: TextStyle(
              fontFamily: logo_font,
              fontWeight: logo_fontweight,
              fontSize: 25,
              color: white,
            ),
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
                'Đăng nhập tài khoản',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: red,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 11,
                  decoration: InputDecoration(
                      hintText: "Nhập số điện thoại",
                      border: InputBorder.none,
                      counterText: ''
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    maxLength: 20,
                    decoration: InputDecoration(
                      hintText: "Nhập mật khẩu",
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

              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.005),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ForgotPassword()),
                      );
                    },
                    child: Text('Quên mật khẩu?', style: TextStyle(color: red)),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.005),
              ElevatedButton(
                onPressed: _signIn,
                child: Text('Đăng Nhập'),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 20),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                  minimumSize: Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: red,
                  foregroundColor: white,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Chưa có tài khoản?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignUp()),
                      );
                    },
                    child: Text('Đăng ký', style: TextStyle(color: red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
