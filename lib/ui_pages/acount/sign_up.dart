import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:transport_assistant/firebase/firebase_auth.dart';
import 'package:transport_assistant/ui_pages/acount/sign_in.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _isPasswordVisible = false;
  final TextEditingController _email    = TextEditingController();
  final TextEditingController _Password = TextEditingController();
  final TextEditingController _uesrname = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _Password.dispose();
    _uesrname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ──
          Image.asset(
            'assets/images/51b7a54fb46ffca4bc9e6e7c5324762cba3f9c83.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/67460f18808338f4f4b8dd938dff42beca7021c8.png',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'welcome_transway'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C2B4A),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Email
                    _buildLabel('Email'.tr()),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _email,
                      hint: 'email_hint'.tr(),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    // Username
                    _buildLabel('Username'.tr()),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _uesrname,
                      hint: 'username_hint'.tr(),
                    ),
                    const SizedBox(height: 14),

                    // Password
                    _buildLabel('Password'.tr()),
                    const SizedBox(height: 6),
                    _buildPasswordField(
                      controller: _Password,
                      hint: 'password_hint'.tr(),
                      obscure: !_isPasswordVisible,
                      onToggle: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    const SizedBox(height: 28),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          AuthHelper()
                              .signUp(
                            email: _email.text,
                            password: _Password.text,
                            userName: _uesrname.text,
                          )
                              .then((result) {
                            if (result == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignIn()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result)),
                              );
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C2B4A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'SignUp'.tr(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'have_account'.tr(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            'Sign in'.tr(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1C2B4A),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // OR divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                              color: Color(0xFF2E3E4B), thickness: 0.8),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'or'.tr(),
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF2E3E4B)),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                              color: Color(0xFF2E3E4B), thickness: 0.8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Google Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA5B9CC),
                          elevation: 1,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CustomPaint(
                                  painter: _GoogleIconPainter()),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'signup_google'.tr(),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C2B4A),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        suffixIcon: IconButton(
          icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
          color:  Color(0xFF1C2B4A),
        ),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'G',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E3E4B),
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}