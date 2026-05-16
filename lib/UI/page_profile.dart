import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_assistant/UI/page_singin.dart';
import 'package:transport_assistant/firebase/firebase_auth.dart';
import 'package:transport_assistant/ui_pages/acount/sign_in.dart';
import 'package:transport_assistant/ui_pages/acount/sign_up.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDark;
  final Function(bool)? onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.isDark,
    this.onThemeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Preferences ──────────────────────────────────────────────────────────
  bool _notificationsEnabled = true;
  late bool _darkModeEnabled;

  // ── Auth / User data ──────────────────────────────────────────────────────
  String? _imgPath;
  User?   _user;
  String? _email;
  String? _name;
  bool    _isLoggedIn = false;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _darkModeEnabled = widget.isDark;
    _checkLoginState();
    _loadUserData();
    _loadUserImage();
  }

  Future<void> _checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isLoggedIn = prefs.getBool('logged_in') ?? false);
  }

  void _loadUserData() {
    _user  = FirebaseAuth.instance.currentUser;
    _email = _user?.email;
    _name  = _user?.displayName;
  }

  Future<void> _loadUserImage() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseStorage.instance.ref().child("users/$uid/profile.jpg");
      final url = await ref.getDownloadURL();
      setState(() => _imgPath = url);
    } catch (e) {
      debugPrint("Error loading user image: $e");
    }
  }

  Future<String> _uploadImageToStorage(String filePath) async {
    final file = File(filePath);
    final uid  = FirebaseAuth.instance.currentUser!.uid;
    final ref  = FirebaseStorage.instance.ref().child("users/$uid/profile.jpg");
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final url = await _uploadImageToStorage(picked.path);
      setState(() => _imgPath = url);
    }
  }

  Future<void> _signOut() async {
    await AuthHelper().signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── BACKGROUND IMAGE ──────────────────────────────────────────────
          SizedBox.expand(
            child: Image.asset(
              'assets/images/photo_2026-05-02_15-51-19.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ── DARK OVERLAY ─────────────────────────────────────────────────
          Container(color: Colors.black.withOpacity(0.25)),

          // ── AVATAR ───────────────────────────────────────────────────────
          Positioned(
            right: 147,
            top: 90,
            child: CircleAvatar(
              radius: 65,
              backgroundColor: const Color(0xFFBECFDF),
              backgroundImage: _imgPath != null
                  ? CachedNetworkImageProvider(_imgPath!) as ImageProvider
                  : null,
              child: _imgPath == null
                  ? const Icon(Icons.person, size: 90, color: Color(0xFF1F2E3B))
                  : null,
            ),
          ),

          // ── ADD / EDIT PHOTO BUTTON ───────────────────────────────────────
          Positioned(
            right: 155,
            top: 190,
            child: GestureDetector(
              onTap: _isLoggedIn ? _pickAndUploadImage : null,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.add,
                  size: 18,
                  color: _isLoggedIn
                      ? const Color(0xFF1F2E3B)
                      : Colors.grey,
                ),
              ),
            ),
          ),

          // ── MAIN CONTENT ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 190.0),
            child: Column(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      _isLoggedIn ? (_name ?? 'No Name') : 'Guest',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isLoggedIn ? (_email ?? '') : 'Not signed in',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    child: _isLoggedIn
                        ? _buildLoggedInContent()
                        : _buildLoggedOutContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // واجهة المستخدم المسجّل
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLoggedInContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        _sectionTitle('About'),
        const SizedBox(height: 10),

        _buildFieldLabel('Email'),
        const SizedBox(height: 4),
        _buildInfoTile(
          icon: Icons.email_outlined,
          value: _email ?? 'No Email',
        ),

        const SizedBox(height: 12),

        _buildFieldLabel('Name'),
        const SizedBox(height: 4),
        _buildInfoTile(
          icon: Icons.person_outline,
          value: _name ?? 'No Name',
        ),

        const SizedBox(height: 24),

        _sectionTitle('Preferences'),
        const SizedBox(height: 10),

        // ── اللغة ──────────────────────────────────────────────────────────
        _buildPreferenceTile(
          icon: Icons.language,
          label: 'Languages',
          trailing: DropdownButton<String>(
            value: context.locale.languageCode,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF263245),
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text('🇬🇧 English',
                    style: TextStyle(color: Colors.grey.shade300)),
              ),
              DropdownMenuItem(
                value: 'ar',
                child: Text('🇸🇦 العربية',
                    style: TextStyle(color: Colors.grey.shade300)),
              ),
              DropdownMenuItem(
                value: 'fr',
                child: Text('🇫🇷 Français',
                    style: TextStyle(color: Colors.grey.shade300)),
              ),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                EasyLocalization.of(context)!.setLocale(Locale(newValue));
                setState(() {});
              }
            },
          ),
        ),

        const SizedBox(height: 4),

        // ── الإشعارات ──────────────────────────────────────────────────────
        _buildPreferenceTile(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
            activeColor:      const Color(0xFF1F2E3B),
            activeTrackColor: const Color(0xFFBECFDF),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ),

        const SizedBox(height: 4),

        // ── الوضع الداكن ───────────────────────────────────────────────────
        _buildPreferenceTile(
          icon: Icons.dark_mode_outlined,
          label: 'Dark Mode',
          trailing: Switch(
            value: _darkModeEnabled,
            onChanged: (v) {
              setState(() => _darkModeEnabled = v);
              widget.onThemeChanged?.call(v);
            },
            activeColor:      const Color(0xFF1F2E3B),
            activeTrackColor: const Color(0xFFBECFDF),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ),

        const SizedBox(height: 16),

        // ── Logout Button ──────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _signOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBECFDF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFF1F2E3B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // واجهة الزائر (غير مسجّل)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLoggedOutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        _sectionTitle('Preferences'),
        const SizedBox(height: 10),

        // ── اللغة ──────────────────────────────────────────────────────────
        _buildPreferenceTile(
          icon: Icons.language,
          label: 'Languages',
          trailing: DropdownButton<String>(
            value: context.locale.languageCode,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF263245),
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text('🇬🇧 English',
                    style: TextStyle(color: Colors.grey.shade300)),
              ),
              DropdownMenuItem(
                value: 'ar',
                child: Text('🇸🇦 العربية',
                    style: TextStyle(color: Colors.grey.shade300)),
              ),
              DropdownMenuItem(
                value: 'fr',
                child: Text('🇫🇷 Français',
                    style: TextStyle(color: Colors.grey.shade300)),
              ),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                EasyLocalization.of(context)!.setLocale(Locale(newValue));
                setState(() {});
              }
            },
          ),
        ),

        const SizedBox(height: 4),

        // ── الإشعارات ──────────────────────────────────────────────────────
        _buildPreferenceTile(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
            activeColor:      const Color(0xFF1F2E3B),
            activeTrackColor: const Color(0xFFBECFDF),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ),

        const SizedBox(height: 4),

        // ── الوضع الداكن ───────────────────────────────────────────────────
        _buildPreferenceTile(
          icon: Icons.dark_mode_outlined,
          label: 'Dark Mode',
          trailing: Switch(
            value: _darkModeEnabled,
            onChanged: (v) {
              setState(() => _darkModeEnabled = v);
              widget.onThemeChanged?.call(v);
            },
            activeColor:      const Color(0xFF1F2E3B),
            activeTrackColor: const Color(0xFFBECFDF),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ),

        const SizedBox(height: 24),

        // ── Sign In Button ─────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SignIn()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBECFDF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: Color(0xFF1F2E3B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Helper Widgets
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      decoration: TextDecoration.underline,
      decorationColor: Colors.white,
    ),
  );

  Widget _buildFieldLabel(String label) => Text(
    label,
    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
  );

  Widget _buildInfoTile(
      {required IconData icon, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF263245),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFBF7F7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white)),
          ),
          const Text('Edit',
              style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required String label,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: Colors.white)),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}