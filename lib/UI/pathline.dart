import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transport_assistant/UI/Taxi_lines.dart';
import 'package:transport_assistant/UI/bus_lines.dart';
import 'package:transport_assistant/UI/mitro.dart';
import 'package:transport_assistant/UI/telefirek_lines.dart';
import 'package:transport_assistant/UI/train_lines.dart';
import 'package:transport_assistant/UI/tram_lines.dart';

class PathLinesScreen extends StatefulWidget {
  final Function(String)? onSelectRoute;
  const PathLinesScreen({super.key, this.onSelectRoute});

  @override
  State<PathLinesScreen> createState() => PathLinesScreenState();
}

class PathLinesScreenState extends State<PathLinesScreen> {
  final List<_PathItem> _items = [];
  Widget? _currentPage;

  // ← دالة الـ reset
  void resetPage() {
    setState(() => _currentPage = null);
  }

  @override
  void initState() {
    super.initState();
    _items.addAll([
      _PathItem(
        label: 'Taxi Line',
        icon: FontAwesomeIcons.taxi,
        page: TaxiLinesScreen(
          onSelectRoute: (lineName) {
            setState(() => _currentPage = null);
            widget.onSelectRoute?.call(lineName);
          },
        ),
      ),
      _PathItem(
        label: 'Bus Line',
        icon: FontAwesomeIcons.bus,
        page: BusLinesScreen(
          onSelectRoute: (lineName) {
            setState(() => _currentPage = null);
            widget.onSelectRoute?.call(lineName);
          },
        ),
      ),
      _PathItem(
        label: 'Train Line',
        icon: FontAwesomeIcons.train,
        page: TrainLinesScreen(
              (lineName) {
            setState(() => _currentPage = null);
            widget.onSelectRoute?.call(lineName);
          },
        ),
      ),
      _PathItem(
        label: 'Tram Line',
        icon: FontAwesomeIcons.trainTram,
        page: TramLinesScreen(
          onSelectRoute: (lineName) {
            setState(() => _currentPage = null);
            widget.onSelectRoute?.call(lineName);
          },
        ),
      ),
      _PathItem(
        label: 'Metro Line',
        icon: FontAwesomeIcons.trainSubway,
        page: MitroLinesScreen(
          onSelectRoute: (lineName) {
            setState(() => _currentPage = null);
            widget.onSelectRoute?.call(lineName);
          },
        ),
      ),
      _PathItem(
        label: 'Telefirik Line',
        icon: FontAwesomeIcons.cableCar,
        page: TeleferikLinesScreen(
          onSelectRoute: (lineName) {
            setState(() => _currentPage = null);
            widget.onSelectRoute?.call(lineName);
          },
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // ← اعرض صفحة الخط إذا تم اختيارها
    if (_currentPage != null) return _currentPage!;

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
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 20),
                const Text(
                  'Path Lines',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: _items.map((item) => _buildCard(item)).toList(),
                    ),
                  ),
                ),
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
          Image.asset(
            'assets/images/ChatGPT_Image_Feb_13__2026__02_39_29_PM-removebg-preview 2.png',
            width: 45,
            height: 45,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
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

  Widget _buildCard(_PathItem item) {
    return GestureDetector(
      onTap: () {
        setState(() => _currentPage = item.page);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFBECFDF).withOpacity(0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFBECFDF), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFF1E2A3A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(item.icon, color: Colors.white, size: 26),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PathItem {
  final String label;
  final FaIconData icon;
  final Widget page;

  _PathItem({
    required this.label,
    required this.icon,
    required this.page,
  });
}