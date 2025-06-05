import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studio_booking_app/constants/colorpalette.dart';
import 'package:studio_booking_app/constants/text-font.dart';
import 'package:studio_booking_app/screens/signIn.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studio_booking_app/screens/signUpInfo.dart';
import 'package:provider/provider.dart';
import 'package:studio_booking_app/providers/userProvider.dart';
import 'package:studio_booking_app/models/userModel.dart';

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  Future<bool> isPhoneTaken(String phone) async {
    final response = await Supabase.instance.client
        .from('UserAcoount')
        .select()
        .eq('userPhoneNumber', phone)
        .maybeSingle();
    return response != null;
  }

  void handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final phone = phoneController.text.trim();
      final password = passwordController.text.trim();
      final isTaken = await isPhoneTaken(phone);

      if (isTaken) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Số điện thoại đã được sử dụng')),
        );
        return;
      }

      try {
        final response = await Supabase.instance.client
            .from('UserAcoount')
            .insert({
          'userPhoneNumber': phone,
          'userPassword': password,
        })
            .select()
            .single();
        print('Supabase response: $response');
        final int userId = response['userId'];
        final userData = UserModel.fromMap(response);
        Provider.of<UserProvider>(context, listen: false).setUser(userData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng ký thành công')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignUpInfo(userId: userId)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi đăng ký: $e')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Đăng ký tài khoản',
                  style: TextStyle(
                    color: red,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 20),

                // Số điện thoại
                buildTextField(
                  controller: phoneController,
                  hintText: 'Nhập số điện thoại',
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (value.length < 10 || value.length > 11) {
                      return 'Số điện thoại phải từ 10 đến 11 chữ số';
                    }
                    if (!RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$').hasMatch(value)) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    if (RegExp(r'^(\d)\1{9,10}$').hasMatch(value)) {
                      return 'Số điện thoại không hợp lệ (quá giống nhau)';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // Mật khẩu
                buildTextField(
                  controller: passwordController,
                  hintText: 'Nhập mật khẩu',
                  obscureText: !showPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => showPassword = !showPassword);
                    },
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    NoWhitespaceInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 10) {
                      return 'Mật khẩu phải có ít nhất 10 ký tự';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // Nhập lại mật khẩu
                buildTextField(
                  controller: confirmPasswordController,
                  hintText: 'Nhập lại mật khẩu',
                  obscureText: !showConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => showConfirmPassword = !showConfirmPassword);
                    },
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    NoWhitespaceInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập lại mật khẩu';
                    }
                    if (value != passwordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 30),

                ElevatedButton(
                  onPressed: handleSignUp,
                  child: Text('Đăng Ký'),
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
                    Text('Đã có tài khoản?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignIn()),
                        );
                      },
                      child: Text('Đăng nhập', style: TextStyle(color: red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    required String? Function(String?) validator,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: grey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }
}

// Chặn nhập khoảng trắng
class NoWhitespaceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.contains(' ')) {
      return oldValue;
    }
    return newValue;
  }
}
