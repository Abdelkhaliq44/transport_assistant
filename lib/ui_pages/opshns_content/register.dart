import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transport_assistant/Data/register.dart';
import 'package:transport_assistant/ui_pages/acount/sign_in.dart';

class Register extends StatefulWidget {
  final Function(double lat, double lng, String name)? onGoToMap;
  const Register({super.key, this.onGoToMap});

  @override
  State<Register> createState() => RegisterState();
}

class RegisterState extends State<Register> {
  int _selectedIndex = -1;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _isLoggedIn = user != null;
    if (_isLoggedIn) {
      lodderegistorpoint();
    } else {
      setState(() => _isLoading = false);
    }
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
      _isLoading = false;
    });
  }

  void _toMap(double lat, double lng, String name) {
    if (widget.onGoToMap != null) {
      widget.onGoToMap!(lat, lng, name);
    }
  }

  // ── Top Bar ──
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2E3E4B).withOpacity(0.85),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 10),
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
                        hintText: 'choose_destination'.tr(),
                        hintStyle: const TextStyle(color: Colors.white, fontSize: 13),
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

  // ── History Card ──
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
            const Icon(Icons.location_on, color: Color(0xFF2E3E4B), size: 25),
            const SizedBox(width: 10),
            Expanded(
              child: Text(name.tr(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 72, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('no_history'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 8),
          Text('no_history_desc'.tr(),
              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4))),
        ],
      ),
    );
  }

  // ── Not Logged In State ──
  Widget _buildNotLoggedInContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFBECFDF).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFFBECFDF).withOpacity(0.3), width: 1.5),
              ),
              child: const Icon(Icons.history, size: 40, color: Color(0xFFBECFDF)),
            ),
            const SizedBox(height: 24),
            const Text(
              "You don't have an account",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Sign in to view your history',
              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const SignIn())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBECFDF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Sign in',
                    style: TextStyle(color: Color(0xFF1F2E3B),
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
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
          SizedBox.expand(
            child: Image.asset('assets/images/background_pathline.jpg', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 20),
                Text('history'.tr(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : !_isLoggedIn
                      ? _buildNotLoggedInContent()
                      : pointregistor.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pointregistor.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _buildHistoryCard(pointregistor[index], index),
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