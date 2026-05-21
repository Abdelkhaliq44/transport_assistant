import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BusLinesScreen extends StatefulWidget {
  final Function(String)? onSelectRoute;
  const BusLinesScreen({super.key, this.onSelectRoute});

  @override
  State<BusLinesScreen> createState() => _BusLinesScreenState();
}

class _BusLinesScreenState extends State<BusLinesScreen> {
  final List<_FavoriteItem> _items = [
    _FavoriteItem(
      titleKey: 'bus_L608A',
      routeKey: 'L608A',
      addressKey: 'bus_L608A_address',
      isFav: true,
      isSelected: false,
    ),
    _FavoriteItem(
      titleKey: 'bus_L58',
      routeKey: 'L58',
      addressKey: 'bus_L58_address',
      isFav: true,
      isSelected: true,
    ),
    _FavoriteItem(
      titleKey: 'bus_L12',
      routeKey: 'L12',
      addressKey: 'bus_L12_address',
      isFav: false,
      isSelected: false,
    ),
    _FavoriteItem(
      titleKey: 'bus_L36',
      routeKey: 'L36',
      addressKey: 'bus_L36_address',
      isFav: true,
      isSelected: false,
    ),
    _FavoriteItem(
      titleKey: 'bus_L89A',
      routeKey: 'L89A',
      addressKey: 'bus_L89A_address',
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
                _buildTopBar(context),
                const SizedBox(height: 20),
                Text(
                  'bus_lines'.tr(),
                  style: const TextStyle(
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

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2E3E4B).withOpacity(0.85),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
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

  Widget _buildFavoriteCard(_FavoriteItem item, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          for (int i = 0; i < _items.length; i++) {
            _items[i] = _FavoriteItem(
              titleKey: _items[i].titleKey,
              routeKey: _items[i].routeKey,
              addressKey: _items[i].addressKey,
              isFav: _items[i].isFav,
              isSelected: i == index,
            );
          }
        });
        widget.onSelectRoute?.call(_items[index].routeKey.trim());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFBECFDF).withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isSelected ? const Color(0xFF4A9EFF) : const Color(0xFF2E4065),
            width: item.isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Icon(
                Icons.location_on,
                color: Color(0xFF2E3E4B),
                size: 25,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.titleKey.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.addressKey.tr(),
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
                      titleKey: _items[index].titleKey,
                      routeKey: _items[index].routeKey,
                      addressKey: _items[index].addressKey,
                      isFav: !_items[index].isFav,
                      isSelected: _items[index].isSelected,
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
  final String titleKey;
  final String routeKey;
  final String addressKey;
  final bool isFav;
  final bool isSelected;

  _FavoriteItem({
    required this.titleKey,
    required this.routeKey,
    required this.addressKey,
    required this.isFav,
    required this.isSelected,
  });
}