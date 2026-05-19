import 'package:flutter/material.dart';
import 'package:transport_assistant/ui_pages/home_page.dart';
import 'package:transport_assistant/UI/page_profile.dart';
import 'package:transport_assistant/UI/pathline.dart';

class MainScreen extends StatefulWidget {
  final bool isDark;
  final Function(bool)? onThemeChanged;

  const MainScreen({
    super.key,
    required this.isDark,
    this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();
  final GlobalKey<PathLinesScreenState> _pathKey = GlobalKey<PathLinesScreenState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      PathLinesScreen(
        key: _pathKey,
        onSelectRoute: (lineName) async {
          setState(() => _selectedIndex = 1);
          await Future.delayed(const Duration(milliseconds: 50));
          await _homeKey.currentState?.onSelectRoute(lineName);
        },
      ),
      HomePage(key: _homeKey),
      ProfileScreen(
        isDark: widget.isDark,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      _NavItem(icon: Icons.map_outlined,         label: 'Path'),
      _NavItem(icon: Icons.location_on_outlined,  label: 'Map'),
      _NavItem(icon: Icons.person_outline,        label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A).withOpacity(0.97),
        border: const Border(
          top: BorderSide(color: Color(0xFF2E3D52), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == _selectedIndex;
          return GestureDetector(
            onTap: () {
              // ← عند الضغط على Path أعد الصفحة لحالتها الأصلية
              if (i == 0) {
                _pathKey.currentState?.resetPage();
              }
              setState(() => _selectedIndex = i);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: selected
                      ? const BoxDecoration(
                    color: Color(0xFF2E3D52),
                    shape: BoxShape.circle,
                  )
                      : null,
                  child: Icon(
                    items[i].icon,
                    color: selected ? Colors.white : Colors.grey.shade500,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  items[i].label,
                  style: TextStyle(
                    fontSize: 11,
                    color: selected ? Colors.white : Colors.grey.shade500,
                    fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}