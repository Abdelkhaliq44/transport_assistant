import 'package:flutter/material.dart';

class R {
  static late MediaQueryData _mq;
  static late double sw; // screen width
  static late double sh; // screen height
  static late double _base;

  static void init(BuildContext context) {
    _mq = MediaQuery.of(context);
    sw = _mq.size.width;
    sh = _mq.size.height;
    _base = sw / 375; // 375 هو عرض iPhone 14 كـ base
  }

  // ── الأحجام ──────────────────────────
  static double w(double v) => sw * (v / 375);   // عرض
  static double h(double v) => sh * (v / 812);   // ارتفاع
  static double r(double v) => _base * v;         // radius / icon
  static double sp(double v) => _base * v;        // font size

  // ── الـ Padding ───────────────────────
  static double get topPad => _mq.padding.top;
  static double get botPad => _mq.padding.bottom;

  // ── نوع الجهاز ────────────────────────
  static bool get isSmall  => sw < 360;           // هواتف صغيرة مثل SE
  static bool get isMedium => sw >= 360 && sw < 410;
  static bool get isLarge  => sw >= 410;          // هواتف كبيرة
  static bool get isTablet => sw >= 600;
}