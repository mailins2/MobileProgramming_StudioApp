import 'package:studio_booking_app/screens/taikhoan_user_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordPage extends StatefulWidget {
  final int userId;

  const ChangePasswordPage({super.key, required this.userId});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();

  bool _isObscuredCurrent = true;
  bool _isObscuredNew = true;
  bool _isObscuredConfirm = true;

  bool isVerified = false;


  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu hiện tại';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới';
    }
    if (value.length < 10) {
      return 'Mật khẩu phải có ít nhất 10 ký tự';
    }
    if (value.length > 20) {
      return 'Mật khẩu không được vượt quá 20 ký tự';
    }
    if (value.contains(' ')) {
      return 'Mật khẩu không được chứa khoảng trắng';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu mới';
    }
    if (value != newPasswordController.text) {
      return 'Mật khẩu nhập lại không khớp';
    }
    return null;
  }

  Future<void> _changePassword() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('UserAcoount')
          .select('userPassword')
          .eq('userId', widget.userId)
          .single();

      final String dbPassword = response['userPassword'];

      if (currentPasswordController.text != dbPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mật khẩu hiện tại không đúng!')),
        );
        return;
      }

      await supabase
          .from('UserAcoount')
          .update({'userPassword': newPasswordController.text})
          .eq('userId', widget.userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi mật khẩu thành công!')),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AccountUserDemo(userID: widget.userId)),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đổi mật khẩu",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 244, 244, 241))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 244, 244, 241)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AccountUserDemo(userID: widget.userId)),
            );
          },
        ),
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 59, 5, 16),
      ),
      body: Container(

        decoration: const BoxDecoration(color: Color.fromARGB(255, 244, 244, 241)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            // child: Column(
            //   children: [
            //     const SizedBox(height: 20),
            //
            //     /// Mật khẩu hiện tại
            //     TextFormField(
            //       controller: currentPasswordController,
            //       obscureText: _isObscuredCurrent,
            //       style: const TextStyle(
            //         color: Color.fromARGB(255, 59, 5, 16),
            //         fontSize: 20,
            //         fontWeight: FontWeight.w500,
            //       ),
            //       decoration: InputDecoration(
            //         hintText: 'Mật khẩu hiện tại',
            //         suffixIcon: IconButton(
            //           icon: Icon(
            //             _isObscuredCurrent ? Icons.visibility_off : Icons.visibility,
            //             color: Colors.grey,
            //           ),
            //           onPressed: () => setState(() => _isObscuredCurrent = !_isObscuredCurrent),
            //         ),
            //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            //         enabledBorder: OutlineInputBorder(
            //           borderSide: const BorderSide(color: Colors.grey, width: 2),
            //           borderRadius: BorderRadius.circular(14),
            //         ),
            //         focusedBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(14),
            //           borderSide: const BorderSide(color: Color.fromARGB(255, 59, 5, 16), width: 2),
            //         ),
            //       ),
            //       validator: _validateCurrentPassword,
            //     ),
            //     const SizedBox(height: 16),
            //
            //     /// Mật khẩu mới
            //     TextFormField(
            //       controller: newPasswordController,
            //       obscureText: _isObscuredNew,
            //       style: const TextStyle(
            //         color: Color.fromARGB(255, 59, 5, 16),
            //         fontSize: 20,
            //         fontWeight: FontWeight.w500,
            //       ),
            //       decoration: InputDecoration(
            //         hintText: 'Mật khẩu mới',
            //         suffixIcon: IconButton(
            //           icon: Icon(
            //             _isObscuredNew ? Icons.visibility_off : Icons.visibility,
            //             color: Colors.grey,
            //           ),
            //           onPressed: () => setState(() => _isObscuredNew = !_isObscuredNew),
            //         ),
            //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            //         enabledBorder: OutlineInputBorder(
            //           borderSide: const BorderSide(color: Colors.grey, width: 2),
            //           borderRadius: BorderRadius.circular(14),
            //         ),
            //         focusedBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(14),
            //           borderSide: const BorderSide(color: Color.fromARGB(255, 59, 5, 16), width: 2),
            //         ),
            //       ),
            //       validator: _validatePassword,
            //     ),
            //     const SizedBox(height: 16),
            //
            //     /// Nhập lại mật khẩu mới
            //     TextFormField(
            //       controller: confirmNewPasswordController,
            //       obscureText: _isObscuredConfirm,
            //       style: const TextStyle(
            //         color: Color.fromARGB(255, 59, 5, 16),
            //         fontSize: 20,
            //         fontWeight: FontWeight.w500,
            //       ),
            //       decoration: InputDecoration(
            //         hintText: 'Nhập lại mật khẩu mới',
            //         suffixIcon: IconButton(
            //           icon: Icon(
            //             _isObscuredConfirm ? Icons.visibility_off : Icons.visibility,
            //             color: Colors.grey,
            //           ),
            //           onPressed: () => setState(() => _isObscuredConfirm = !_isObscuredConfirm),
            //         ),
            //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            //         enabledBorder: OutlineInputBorder(
            //           borderSide: const BorderSide(color: Colors.grey, width: 2),
            //           borderRadius: BorderRadius.circular(14),
            //         ),
            //         focusedBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(14),
            //           borderSide: const BorderSide(color: Color.fromARGB(255, 59, 5, 16), width: 2),
            //         ),
            //       ),
            //       validator: _validateConfirmPassword,
            //     ),
            //
            //     const Spacer(),
            //
            //     /// Nút Lưu
            //     SizedBox(
            //       width: double.infinity,
            //       height: 50,
            //       child: ElevatedButton(
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: const Color.fromARGB(255, 59, 5, 16),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //         ),
            //         onPressed: () async {
            //           if (_formKey.currentState!.validate()) {
            //             await _changePassword();
            //           }
            //         },
            //         child: const Text(
            //           'Lưu',
            //           style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(height: 24),
            //   ],
            // ),

              child: Column(
                children: [
                  const SizedBox(height: 20),

                  /// Nhập mật khẩu hiện tại
                  TextFormField(
                    controller: currentPasswordController,
                    obscureText: _isObscuredCurrent,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 59, 5, 16),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Mật khẩu hiện tại',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscuredCurrent ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => _isObscuredCurrent = !_isObscuredCurrent),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 59, 5, 16), width: 2),
                      ),
                    ),
                    validator: _validateCurrentPassword,
                  ),
                  const SizedBox(height: 12),

                  /// Nút xác minh mật khẩu hiện tại
                  if (!isVerified)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          if (currentPasswordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập mật khẩu hiện tại')),
                            );
                            return;
                          }

                          try {
                            final supabase = Supabase.instance.client;
                            final response = await supabase
                                .from('UserAcoount')
                                .select('userPassword')
                                .eq('userId', widget.userId)
                                .single();

                            final dbPassword = response['userPassword'];

                            if (currentPasswordController.text == dbPassword) {
                              setState(() {
                                isVerified = true;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Mật khẩu hiện tại không đúng!')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi: $e')),
                            );
                          }
                        },
                        child: const Text(
                          'Xác minh',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),

                  if (isVerified) ...[
                    const SizedBox(height: 20),

                    /// Mật khẩu mới
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: _isObscuredNew,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 59, 5, 16),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Mật khẩu mới',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscuredNew ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _isObscuredNew = !_isObscuredNew),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 59, 5, 16), width: 2),
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 16),

                    /// Xác nhận mật khẩu mới
                    TextFormField(
                      controller: confirmNewPasswordController,
                      obscureText: _isObscuredConfirm,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 59, 5, 16),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập lại mật khẩu mới',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscuredConfirm ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _isObscuredConfirm = !_isObscuredConfirm),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 59, 5, 16), width: 2),
                        ),
                      ),
                      validator: _validateConfirmPassword,
                    ),
                    const Spacer(),

                    /// Nút Lưu
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 59, 5, 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final supabase = Supabase.instance.client;

                            try {
                              await supabase
                                  .from('UserAcoount')
                                  .update({'userPassword': newPasswordController.text})
                                  .eq('userId', widget.userId);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đổi mật khẩu thành công!')),
                              );

                              Future.delayed(const Duration(milliseconds: 500), () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => AccountUserDemo(userID: widget.userId)),
                                );
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi: $e')),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Lưu',
                          style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              )

          ),
        ),
      ),
    );
  }
}


