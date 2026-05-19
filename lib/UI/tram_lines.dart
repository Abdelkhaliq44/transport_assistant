import 'package:flutter/material.dart';

class TramLinesScreen extends StatefulWidget {
  final Function(String)? onSelectRoute; // ← أضف
  const TramLinesScreen({super.key, this.onSelectRoute}); // ← عدّل

  @override
  State<TramLinesScreen> createState() => _TramLinesScreenState();
}

class _TramLinesScreenState extends State<TramLinesScreen> {
  final List<_FavoriteItem> _items = List.generate(
    1,
        (i) => _FavoriteItem(
      title: 'tram',
      address: 'Dergana,Ruisseau',
      isFav: true,
      isSelected: i == 3,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background_pathline.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 20),
                const Text(
                  'Tram Lines',
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

  Widget _buildFavoriteCard(_FavoriteItem item, int index) {
    return GestureDetector(
      onTap: () {
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
        // ← استدعي الـ callback ثم ارجع
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
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Icon(Icons.location_on, color: Color(0xFF2E3E4B), size: 25),
            ),
            const SizedBox(width: 10),
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
                  const SizedBox(height: 4),
                  Text(
                    item.address,
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
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