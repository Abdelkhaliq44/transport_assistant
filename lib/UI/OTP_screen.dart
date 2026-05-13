import 'package:flutter/material.dart';
import 'package:transport_assistant/UI/ResetPassword.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<String> _otp = ['', '', '', ''];
  int _currentIndex = 0;

  void _onKeyTap(String value) {
    if (_currentIndex < 4) {
      setState(() {
        _otp[_currentIndex] = value;
        _currentIndex++;
      });
    }
  }

  void _onDelete() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _otp[_currentIndex] = '';
      });
    }
  }

  void _onVerify() {
    final code = _otp.join();
    if (code.length == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // ── Top section with background ──
          Expanded(
            flex: 55,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.asset(
                  'assets/images/forgetpassword.jpg',
                  fit: BoxFit.cover,
                ),

                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                // Back button
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 0, 0),
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back_ios_new,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                // Logo
                                Image.asset(
                                  'assets/images/ChatGPT_Image_Feb_13__2026__02_39_29_PM-removebg-preview 2.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 20),

                                // Title
                                const Text(
                                  'Enter Your OTP',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Description
                                Text(
                                  'Check your email and enter the code to\nreset your password',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade400,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // OTP boxes
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(4, (i) => _buildOtpBox(i)),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Verify Now button
                                // ── Verify Now button ──
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _onVerify,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFBECFDF),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text(
                                        'Verify Now',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2E3E4B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Custom Keyboard ──
          Expanded(
            flex: 45,
            child: Container(
              color: const Color(0xFFE8ECF0),
              child: _buildKeyboard(),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // OTP Box
  // ─────────────────────────────────────────────
  Widget _buildOtpBox(int index) {
    final isFilled  = _otp[index].isNotEmpty;
    final isCurrent = index == _currentIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF3A4F65).withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? Colors.white.withOpacity(0.8)
              : Colors.white.withOpacity(0.2),
          width: isCurrent ? 1.8 : 1,
        ),
      ),
      child: Center(
        child: isFilled
            ? Text(
          _otp[index],
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )
            : isCurrent
            ? Container(
          width: 2,
          height: 26,
          color: Colors.white.withOpacity(0.7),
        )
            : null,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Custom Keyboard
  // ─────────────────────────────────────────────
  Widget _buildKeyboard() {
    final keys = [
      ['1', '2\nABC', '3\nDEF'],
      ['4\nGHI', '5\nJKL', '6\nMNO'],
      ['7\nPQRS', '8\nTUV', '9\nWXYZ'],
      ['', '0', 'del'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: keys.map((row) {
          return Expanded(
            child: Row(
              children: row.map((key) {
                if (key.isEmpty) return const Expanded(child: SizedBox());
                if (key == 'del') return Expanded(child: _buildDeleteKey());
                return Expanded(child: _buildKey(key));
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKey(String label) {
    final parts  = label.split('\n');
    final number = parts[0];
    final sub    = parts.length > 1 ? parts[1] : '';

    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: () => _onKeyTap(number),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              if (sub.isNotEmpty)
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    letterSpacing: 1.2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: _onDelete,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: Colors.black54,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}