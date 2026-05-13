import 'package:flutter/material.dart';
import 'package:transport_assistant/UI/navigator_barre.dart';
import 'package:transport_assistant/UI/page_home.dart' show MapScreen;
import 'package:transport_assistant/UI/page_singup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background: light grey with faint map-road pattern ──
          _MapBackground(),

          // ── Content centered on screen ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    const _TransWayLogo(),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Welcome Back To TransWay',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C2B4A),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email field
                    _buildLabel('Email'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    // Password field
                    _buildLabel('Password'),
                    const SizedBox(height: 6),
                    _buildPasswordField(),
                    const SizedBox(height: 28),

                    // Sign In button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                        );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C2B4A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color( 0xFFD7E4F1),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Don't have an account?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1C2B4A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUpScreen()),
                          );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
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
                        Expanded(
                          child: Divider(
                            color: Color(0xFF2E3E4B),
                            thickness: 0.8,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'or',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2E3E4B),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Color(0xFF2E3E4B),
                            thickness: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sign In with Google
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA5B9CC),
                          foregroundColor: const Color(0xFFA5B9CC),
                          elevation: 1,
                          shadowColor: Colors.black26,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _GoogleIcon(),
                            const SizedBox(width: 10),
                            const Text(
                              'Sign In with Google',
                              style: TextStyle(
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
      style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white60, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.35),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF1C2B4A), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
      decoration: InputDecoration(
        hintText: 'Enter your password',
        hintStyle: TextStyle(color: Colors.white60, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.35),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white60, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF1C2B4A), width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey.shade400,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TransWay Logo  (drawn with CustomPainter)
// ─────────────────────────────────────────────
class _TransWayLogo extends StatelessWidget {
  const _TransWayLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/67460f18808338f4f4b8dd938dff42beca7021c8.png',
      width: 150,
      height: 150,
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1C2B4A)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Left leg of the "A" shape (road/arrow style)
    final leftPath = Path()
      ..moveTo(w * 0.08, h * 0.85)
      ..lineTo(w * 0.38, h * 0.15)
      ..lineTo(w * 0.50, h * 0.32);
    canvas.drawPath(leftPath, paint);

    // Right leg
    final rightPath = Path()
      ..moveTo(w * 0.92, h * 0.85)
      ..lineTo(w * 0.62, h * 0.15)
      ..lineTo(w * 0.50, h * 0.32);
    canvas.drawPath(rightPath, paint);

    // Crossbar (slightly curved like a road)
    final crossPath = Path()
      ..moveTo(w * 0.24, h * 0.60)
      ..quadraticBezierTo(w * 0.50, h * 0.50, w * 0.76, h * 0.60);
    canvas.drawPath(crossPath, paint);

    // Top arrow tip
    final tipPaint = Paint()
      ..color = const Color(0xFF1C2B4A)
      ..style = PaintingStyle.fill;

    final tipPath = Path()
      ..moveTo(w * 0.50, h * 0.05)
      ..lineTo(w * 0.42, h * 0.20)
      ..lineTo(w * 0.58, h * 0.20)
      ..close();
    canvas.drawPath(tipPath, tipPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// Map Background  (faint road lines on grey)
// ─────────────────────────────────────────────
class _MapBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/51b7a54fb46ffca4bc9e6e7c5324762cba3f9c83.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = const Color(0xFFB8BCC4).withOpacity(0.55)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final highway = Paint()
      ..color = const Color(0xFFA8ADB8).withOpacity(0.45)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Horizontal roads
    for (int i = 1; i <= 9; i++) {
      double y = h * i / 10;
      canvas.drawLine(Offset(0, y), Offset(w, y), road);
    }

    // Vertical roads
    for (int i = 1; i <= 5; i++) {
      double x = w * i / 6;
      canvas.drawLine(Offset(x, 0), Offset(x, h), road);
    }

    // Diagonal highways
    canvas.drawLine(Offset(0, h * 0.1), Offset(w * 0.7, h * 0.95), highway);
    canvas.drawLine(Offset(w * 0.3, 0), Offset(w, h * 0.8), highway);
    canvas.drawLine(Offset(0, h * 0.5), Offset(w * 0.45, h), highway);
    canvas.drawLine(Offset(w * 0.6, 0), Offset(w * 0.15, h), highway);

    // Curved road (arc)
    final arcPaint = Paint()
      ..color = const Color(0xFFA0A5B0).withOpacity(0.40)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final arcPath = Path()
      ..moveTo(0, h * 0.3)
      ..quadraticBezierTo(w * 0.5, h * 0.1, w, h * 0.5);
    canvas.drawPath(arcPath, arcPaint);

    final arcPath2 = Path()
      ..moveTo(0, h * 0.75)
      ..quadraticBezierTo(w * 0.4, h * 0.9, w, h * 0.65);
    canvas.drawPath(arcPath2, arcPaint);

    // Small block shapes (city blocks)
    final blockPaint = Paint()
      ..color = const Color(0xFF9DA3AE).withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final blocks = [
      Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.12, h * 0.06),
      Rect.fromLTWH(w * 0.22, h * 0.08, w * 0.10, h * 0.05),
      Rect.fromLTWH(w * 0.60, h * 0.12, w * 0.14, h * 0.07),
      Rect.fromLTWH(w * 0.10, h * 0.75, w * 0.18, h * 0.06),
      Rect.fromLTWH(w * 0.70, h * 0.70, w * 0.20, h * 0.08),
      Rect.fromLTWH(w * 0.40, h * 0.82, w * 0.15, h * 0.05),
    ];

    for (final b in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(b, const Radius.circular(3)),
        blockPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// Google "G" Icon  (drawn manually)
// ─────────────────────────────────────────────
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;



    // Draw simplified "G"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'G',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E3E4B),
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
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
