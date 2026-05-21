import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigator_barre.dart';

// ── بيانات الشرائح ───────────────────────────
class OnboardingPage {
  final String backgroundImage;
  final String vehicleImage;
  final String title;
  final String description;

  const OnboardingPage({
    required this.backgroundImage,
    required this.vehicleImage,
    required this.title,
    required this.description,
  });
}

const List<OnboardingPage> pages = [
  OnboardingPage(
    backgroundImage: 'assets/images/background_pathline.jpg',
    vehicleImage:
    'assets/images/—Pngtree—online taxi or rent transportation_14993982 1.png',
    title: 'Find a Taxi Near You',
    description:
    'See all nearby taxis in real time and get a ride quickly from your location.',
  ),
  OnboardingPage(
    backgroundImage: 'assets/images/background_pathline.jpg',
    vehicleImage:
    'assets/images/ChatGPT_Image_Mar_24__2026__06_57_30_PM-removebg-preview 2.png',
    title: 'Track Buses Easily',
    description:
    'Check bus routes, locations, and arrival times near you with live updates.',
  ),
  OnboardingPage(
    backgroundImage: 'assets/images/background_pathline.jpg',
    vehicleImage:
    'assets/images/ChatGPT_Image_Mar_24__2026__06_57_51_PM-removebg-preview 1.png',
    title: 'Follow Trains in Real Time',
    description:
    'Find nearby trains, view schedules, and track their movement on the map.',
  ),
];

// ── الشاشة الرئيسية ──────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _displayedIndex = 0;
  int _currentIndex = 0;
  bool _isAnimating = false;

  late AnimationController _vehicleCtrl;
  late Animation<Offset>   _vehicleSlide;
  late Animation<double>   _vehicleFade;
  late Animation<double>   _vehicleScale;

  late AnimationController _textCtrl;
  late Animation<Offset>   _textSlide;
  late Animation<double>   _textFade;

  late AnimationController _floatCtrl;
  late Animation<double>   _floatAnim;

  @override
  void initState() {
    super.initState();
    _buildControllers();
    _playEntrance();
  }

  void _buildControllers() {
    _vehicleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));

    _vehicleSlide = Tween<Offset>(
        begin: const Offset(1.3, 0), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _vehicleCtrl, curve: Curves.easeOutCubic));

    _vehicleFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _vehicleCtrl,
        curve: const Interval(0, 0.65, curve: Curves.easeIn)));

    _vehicleScale = Tween<double>(begin: 0.72, end: 1).animate(
        CurvedAnimation(parent: _vehicleCtrl, curve: Curves.easeOutBack));

    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));

    _textSlide = Tween<Offset>(
        begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _textCtrl, curve: Curves.easeOutCubic));

    _textFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -10, end: 10).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  Future<void> _playEntrance() async {
    _vehicleCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 220));
    _textCtrl.forward(from: 0);
  }

  Future<void> _goToPage(int newIndex) async {
    if (_isAnimating || newIndex == _currentIndex) return;
    _isAnimating = true;

    setState(() => _currentIndex = newIndex);

    await Future.wait([
      _vehicleCtrl.reverse(),
      _textCtrl.reverse(),
    ]);

    setState(() => _displayedIndex = newIndex);
    await _playEntrance();

    _isAnimating = false;
  }

  void _next() {
    if (_currentIndex < pages.length - 1) {
      _goToPage(_currentIndex + 1);
    } else {
      _finishOnboarding();
    }
  }

  void _back() {
    if (_currentIndex > 0) {
      _goToPage(_currentIndex - 1);
    }
  }

  // ── حفظ أن المستخدم شاهد الـ onboarding والانتقال ──
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(
            isDark: false,
            onThemeChanged: (_) {},
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _vehicleCtrl.dispose();
    _textCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = pages[_displayedIndex];
    final isFirst = _currentIndex == 0;
    final isLast  = _currentIndex == pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF1B2A3B),
      body: Stack(
        children: [
          // ── خلفية ──
          Positioned.fill(
            child: Image.asset(page.backgroundImage, fit: BoxFit.cover),
          ),

          // ── gradient ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x221B2A3B),
                    Color(0x771B2A3B),
                    Color(0xEE1B2A3B),
                    Color(0xFF1B2A3B),
                  ],
                  stops: [0.0, 0.35, 0.62, 1.0],
                ),
              ),
            ),
          ),

          // ── Skip ──
          Positioned(
            top: 52,
            right: 24,
            child: AnimatedOpacity(
              opacity: isLast ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: TextButton(
                onPressed: isLast ? null : _finishOnboarding,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  backgroundColor: Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // ── صورة المركبة ──
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _vehicleSlide,
              child: FadeTransition(
                opacity: _vehicleFade,
                child: ScaleTransition(
                  scale: _vehicleScale,
                  child: AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: child,
                    ),
                    child: Image.asset(
                      page.vehicleImage,
                      height: 440,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── النص ──
          Positioned(
            left: 28,
            right: 28,
            bottom: 160,
            child: SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFB0BEC5),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── الشريط السفلي ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(
              currentIndex: _currentIndex,
              total: pages.length,
              isFirst: isFirst,
              isLast: isLast,
              onBack: _back,
              onNext: _next,
              onDotTap: _goToPage,
              onFinish: _finishOnboarding,
            ),
          ),
        ],
      ),
    );
  }
}

// ── الشريط السفلي ────────────────────────────
class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final ValueChanged<int> onDotTap;
  final VoidCallback onFinish; // ← جديد

  const _BottomBar({
    required this.currentIndex,
    required this.total,
    required this.isFirst,
    required this.isLast,
    required this.onBack,
    required this.onNext,
    required this.onDotTap,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1B2A3B),
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 44),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── النقاط ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(total, (i) {
              final active = i == currentIndex;
              return GestureDetector(
                onTap: () => onDotTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back
              AnimatedOpacity(
                opacity: isFirst ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: isFirst ? null : onBack,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

              // Next / Get Started
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: ElevatedButton(
                  key: ValueKey(isLast),
                  onPressed: isLast ? onFinish : onNext, // ← يستخدم onFinish
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLast
                        ? const Color(0xFF1976D2)
                        : const Color(0xFF2C4A6E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isLast ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}