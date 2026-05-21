import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_assistant/ui_pages/acount/sign_in.dart';

class HistoryPlacesPage extends StatefulWidget {
  const HistoryPlacesPage({super.key});

  @override
  State<HistoryPlacesPage> createState() => _HistoryPlacesPageState();
}

class _HistoryPlacesPageState extends State<HistoryPlacesPage> {
  bool _isLoggedIn = false;

  final List<_FavoriteItem> _items = List.generate(
    5,
        (i) => _FavoriteItem(
      title: 'International Conference Center',
      subtitle: 'Abdelatif Rahal',
      address: 'Route De Cheraga, Ain Benian, Algeries,Algeria',
      isFav: true,
      isSelected: i == 3,
    ),
  );

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isLoggedIn = prefs.getBool('logged_in') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── BACKGROUND IMAGE ──
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background_pathline.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ── DARK OVERLAY ──
          Container(color: Colors.black.withOpacity(0.3)),

          // ── CONTENT ──
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 20),
                const Text(
                  'Historique Points',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoggedIn
                      ? ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _buildFavoriteCard(_items[index], index),
                  )
                      : _buildNotLoggedInContent(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Not Logged In ──
  Widget _buildNotLoggedInContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFBECFDF).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                size: 36,
                color: Color(0xFFBECFDF),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "You don't have an account",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to view your history',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
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
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    color: Color(0xFF1F2E3B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Search Bar ──
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Image.asset(
              'assets/images/ChatGPT_Image_Feb_13__2026__02_39_29_PM-removebg-preview 2.png',
              fit: BoxFit.contain,
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
                      style:
                      const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Choose your destination',
                        hintStyle:
                        TextStyle(color: Colors.white, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(Icons.search,
                        color: Colors.grey.shade400, size: 20),
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
  Widget _buildFavoriteCard(_FavoriteItem item, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          for (int i = 0; i < _items.length; i++) {
            _items[i] = _FavoriteItem(
              title: _items[i].title,
              subtitle: _items[i].subtitle,
              address: _items[i].address,
              isFav: _items[i].isFav,
              isSelected: i == index,
            );
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFBECFDF).withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isSelected
                ? const Color(0xFF4A9EFF)
                : const Color(0xFF2E4065),
            width: item.isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Icon(Icons.location_on,
                  color: Color(0xFF2E3E4B), size: 25),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(item.address,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _items[index] = _FavoriteItem(
                      title: item.title,
                      subtitle: item.subtitle,
                      address: item.address,
                      isFav: !item.isFav,
                      isSelected: item.isSelected,
                    );
                  });
                },
                child: Icon(
                  item.isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _FavoriteItem {
  final String title;
  final String subtitle;
  final String address;
  final bool isFav;
  final bool isSelected;

  _FavoriteItem({
    required this.title,
    required this.subtitle,
    required this.address,
    required this.isFav,
    required this.isSelected,
  });
}