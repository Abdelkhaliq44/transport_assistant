import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transport_assistant/Data/register.dart';
import 'package:transport_assistant/Data/saved_pints.dart';
import '../../Data/favorite_points.dart';

class Register extends StatefulWidget {
  final Function(double lat, double lng, String name)? onGoToMap;
  const Register({super.key, this.onGoToMap});

  @override
  State<Register> createState() => RegisterState();
}

class RegisterState extends State<Register> {
  int _selectedIndex = -1; // لا يوجد عنصر محدد في البداية

  @override
  void initState() {
    super.initState();
    lodderegistorpoint();
  }

  lodderegistorpoint() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    var snapshot = await FirebaseFirestore.instance
        .collection('gistorpoint')
        .doc(uid)
        .get();

    Map<String, dynamic> data = snapshot.data() ?? {};

    List<String> sortedKeys = data.keys.toList()
      ..sort((a, b) {
        int numA = int.tryParse(a.replaceAll('line', '')) ?? 0;
        int numB = int.tryParse(b.replaceAll('line', '')) ?? 0;
        return numA.compareTo(numB);
      });

    List<List<String>> loadedLines = sortedKeys
        .map((key) => (data[key] as List<dynamic>)
        .map((v) => v.toString())
        .toList())
        .toList();

    setState(() {
      pointregistor = loadedLines;
    });
  }

  void _toMap(double lat, double lng, String name) {
    if (widget.onGoToMap != null) {
      widget.onGoToMap!(lat, lng, name);
    }
  }

  // ── Top Search Bar (من SavedPointsScreen) ──
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Logo
          SizedBox(
            width: 36,
            height: 36,
            child: Image.asset(
              'assets/images/ChatGPT_Image_Feb_13__2026__02_39_29_PM-removebg-preview 2.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),

          // Search field
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Choose your destination',
                        hintStyle: TextStyle(color: Colors.white, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── بطاقة كل عنصر (تصميم SavedPointsScreen + منطق Register) ──
  Widget _buildHistoryCard(List<String> line, int index) {
    final name = line[0];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);

        final lat = double.tryParse(line[1].toString().replaceAll(',', '.')) ?? 0.0;
        final lng = double.tryParse(line[2].toString().replaceAll(',', '.')) ?? 0.0;

        _toMap(lat, lng, name);
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFBECFDF).withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A9EFF) : const Color(0xFF2E4065),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // أيقونة الموقع
            Icon(
              Icons.location_on,
              color: const Color(0xFF2E3E4B),
              size: 25,
            ),
            const SizedBox(width: 10),

            // النص
            Expanded(
              child: Text(
                name.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // أيقونة السهم للإشارة إلى الانتقال للخريطة
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── خلفية الصورة ──
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background_pathline.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ── طبقة داكنة فوق الخلفية ──
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // ── المحتوى الرئيسي ──
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 20),

                Text(
                  'history'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: pointregistor.isEmpty
                      ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pointregistor.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _buildHistoryCard(pointregistor[index], index);
                    },
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}