import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'about.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController; // ← للـ pulse المستمر

  late Animation<double> _fadeIn;
  late Animation<double> _scaleIntro;
  late Animation<double> _slideUp;
  late Animation<double> _shimmerAnim;
  late Animation<double> _pulseScale; // ← يكبر ويصغر باستمرار
  late Animation<double> _glowAnim;   // ← الهالة مع الـ pulse

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // ── 1. Intro: يظهر اللوغو لأول مرة ──
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // ── 2. Shimmer يمر باستمرار ──
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // ── 3. Pulse: يكبر ويصغر بلا توقف ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // ── Fade In ──
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // ── Slide Up ──
    _slideUp = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );

    // ── Scale bounce عند الدخول فقط ──
    _scaleIntro = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.55, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 0.97)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.97, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
    ]).animate(_logoController);

    // ── Pulse scale: 1.0 → 1.08 → 1.0 بلا توقف ──
    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Glow يتبع الـ pulse ──
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Shimmer sweep ──
    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // ── تشغيل بالترتيب ──
// شغّلهم مباشرة
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat(
      period: const Duration(milliseconds: 2400),
    );

// ومن بعد intro وحدو
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 3600), () {
      if (mounted) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OnboardingScreen(

            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Background ──
          Image.asset(
            'assets/images/splash_background.jpg',
            fit: BoxFit.cover,
          ),

          // ── 2. Dark overlay ──
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.52),
                  Colors.black.withOpacity(0.25),
                ],
              ),
            ),
          ),

          // ── 3. Glow + Logo معاً يتنفسان ──
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_logoController, _pulseController]),
              builder: (_, child) {
                // الـ scale الكلي = intro scale × pulse scale
                // بعد انتهاء الـ intro، _scaleIntro = 1.0 دائماً
                final totalScale = _scaleIntro.value * _pulseScale.value;

                return FadeTransition(
                  opacity: _fadeIn,
                  child: Transform.translate(
                    offset: Offset(0, _slideUp.value),
                    child: Transform.scale(
                      scale: totalScale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // ── Glow الخارجي الكبير ──
                          Container(
                            width: size.width * 0.90,
                            height: size.width * 0.90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFBECFDF)
                                      .withOpacity(0.13 * _glowAnim.value),
                                  blurRadius: 140,
                                  spreadRadius: 60,
                                ),
                              ],
                            ),
                          ),

                          // ── Glow الداخلي الناعم ──
                          Container(
                            width: size.width * 0.55,
                            height: size.width * 0.55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white
                                      .withOpacity(0.07 * _glowAnim.value),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          ),

                          // ── Logo مع shimmer ──
                          AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (_, child) => ShaderMask(
                              blendMode: BlendMode.srcATop,
                              shaderCallback: (bounds) {
                                final s = _shimmerAnim.value;
                                return LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: const [
                                    Colors.white,
                                    Colors.white,
                                    Color(0xFFDDEEFF),
                                    Colors.white,
                                    Colors.white,
                                  ],
                                  stops: [
                                    0.0,
                                    (s - 0.22).clamp(0.0, 1.0),
                                    s.clamp(0.0, 1.0),
                                    (s + 0.22).clamp(0.0, 1.0),
                                    1.0,
                                  ],
                                ).createShader(bounds);
                              },
                              child: child!,
                            ),
                            child: Image.asset(
                              'assets/images/Group 55.png',
                              width: size.width * 0.82,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── 4. Dots loader ──
          Positioned(
            bottom: size.height * 0.09,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (_, child) => FadeTransition(
                opacity: _fadeIn,
                child: child,
              ),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final phase = i / 3.0;
                      final raw =
                          (_pulseController.value - phase + 1.0) % 1.0;
                      final t =
                      (1.0 - (raw * 2 - 1.0).abs()).clamp(0.0, 1.0);
                      final dotSize = 5.0 + 4.0 * t;
                      final opacity = 0.35 + 0.65 * t;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(opacity),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}