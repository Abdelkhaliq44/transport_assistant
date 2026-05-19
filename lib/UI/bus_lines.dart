import 'package:flutter/material.dart';

class BusLinesScreen extends StatefulWidget {
  final Function(String)? onSelectRoute;
  const BusLinesScreen({super.key, this.onSelectRoute});

  @override
  State<BusLinesScreen> createState() => _BusLinesScreenState();
}

class _BusLinesScreenState extends State<BusLinesScreen> {
  int _selectedNavIndex = 1; // Favorites is selected

  // Favorite items list — index 3 is selected/highlighted
  final List<_FavoriteItem> _items = [
    _FavoriteItem(
      title: ' L608A',

      address: 'Dergana,Haach',
      isFav: true,
      isSelected: false,
    ),

    _FavoriteItem(
      title: 'L58',
      address: 'Place des Martyrs,chevally',
      isFav: true,
      isSelected: true,
    ),

    _FavoriteItem(
      title: 'L12',
      address: 'Staoueli,Place des Martyrs',
      isFav: false,
      isSelected: false,
    ),

    _FavoriteItem(
      title: 'L36',
      address: 'Beaux Arts,Basta ALi',
      isFav: true,
      isSelected: false,
    ),

    _FavoriteItem(
      title: 'L89A',
      address: 'kouba,Place du 1er Mai',
      isFav: false,
      isSelected: false,
    ),
  ];

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

          // ── DARK OVERLAY (اختياري) ──
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // ── CONTENT (نفس كودك بلا تبديل) ──
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 20),

                const Text(
                  'Bus Lines',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _buildFavoriteCard(_items[index], index);
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

  // ── Top Search Bar ──
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
              'assets/images/ChatGPT_Image_Feb_13__2026__02_39_29_PM-removebg-preview 2.png', // حط اسم الصورة تاعك هنا
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
                      style:
                      const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Choose your destination',
                        hintStyle: TextStyle(
                            color: Colors.white, fontSize: 13),
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

  // ── Favorite Card ──
  Widget _buildFavoriteCard(_FavoriteItem item, int index) {
    return GestureDetector(
      // ✅ صحيح — onSelectRoute خارج setState وخارج الـ loop
      onTap: () {
        print("🟢 تم الضغط على: ${_items[index].title.trim()}"); // ← أضف هذا
        setState(() {
          for (int i = 0; i < _items.length; i++) {
            _items[i] = _FavoriteItem(
              title: _items[i].title,
              address: _items[i].address,
              isFav: _items[i].isFav,
              isSelected: i == index,
            );
          }
        });
        widget.onSelectRoute?.call(_items[index].title.trim());

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
            // Location pin icon
            Padding(
              padding: const EdgeInsets.only(top:   20),
              child: Icon(
                Icons.location_on,
                color: Color(0xFF2E3E4B),
                size: 25,
              ),
            ),
            const SizedBox(width: 10),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),

                  const SizedBox(height: 4),
                  Text(
                    item.address,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Heart icon
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: GestureDetector(
                // ✅ صحيح — onSelectRoute خارج setState وخارج الـ loop
                onTap: () {
                  print("🟢 تم الضغط على: ${_items[index].title.trim()}"); // ← أضف هذا
                  setState(() {
                    for (int i = 0; i < _items.length; i++) {
                      _items[i] = _FavoriteItem(
                        title: _items[i].title,
                        address: _items[i].address,
                        isFav: _items[i].isFav,
                        isSelected: i == index,
                      );
                    }
                  });
                  widget.onSelectRoute?.call(_items[index].title.trim());

                },
                child: Icon(
                  item.isFav ? Icons.favorite : Icons.favorite_border,
                  color: item.isFav ? Colors.white : Colors.white, // لون كي يكون مفعل
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Navigation Bar ──

}

// ─────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────
class _FavoriteItem {

  final String title;
  final String address;
  final bool isFav;
  final bool isSelected;

  _FavoriteItem({
    required this.title,
    required this.address,
    required this.isFav,
    required this.isSelected,
  });
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}

// ─────────────────────────────────────────────
// TransWay Logo Painter
// ─────────────────────────────────────────────
class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.08, h * 0.85)
        ..lineTo(w * 0.38, h * 0.15)
        ..lineTo(w * 0.50, h * 0.32),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.92, h * 0.85)
        ..lineTo(w * 0.62, h * 0.15)
        ..lineTo(w * 0.50, h * 0.32),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.24, h * 0.60)
        ..quadraticBezierTo(w * 0.50, h * 0.50, w * 0.76, h * 0.60),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.50, h * 0.05)
        ..lineTo(w * 0.42, h * 0.20)
        ..lineTo(w * 0.58, h * 0.20)
        ..close(),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}