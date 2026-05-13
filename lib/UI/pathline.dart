import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transport_assistant/UI/Taxi_lines.dart';
import 'package:transport_assistant/UI/bus_lines.dart';
import 'package:transport_assistant/UI/mitro.dart';
import 'package:transport_assistant/UI/telefirek_lines.dart';
import 'package:transport_assistant/UI/train_lines.dart';
import 'package:transport_assistant/UI/tram_lines.dart';

class PathLinesScreen extends StatefulWidget {
  const PathLinesScreen({super.key});

  @override
  State<PathLinesScreen> createState() => _PathLinesScreenState();
}

class _PathLinesScreenState extends State<PathLinesScreen> {


  final List<_PathItem> _items = [
    _PathItem(label: 'Taxi Line',     icon: FontAwesomeIcons.taxi,        page: const TaxiLinesScreen()),
    _PathItem(label: 'Bus Line',      icon: FontAwesomeIcons.bus,         page: const BusLinesScreen()),
    _PathItem(label: 'Train Line',    icon: FontAwesomeIcons.train,       page: const TrainLinesScreen()),
    _PathItem(label: 'Tram Line',     icon: FontAwesomeIcons.trainTram,   page: const TramLinesScreen()),
    _PathItem(label: 'Metro Line',    icon: FontAwesomeIcons.trainSubway, page: const MitroLinesScreen()),
    _PathItem(label: 'Telefirik Line',icon: FontAwesomeIcons.cableCar,    page: const TeleferikLinesScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Background Image ──
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background_pathline.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ── Dark Overlay ──
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          // ── Content ──
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
                      children: _items
                          .map((item) => _buildCard(item))
                          .toList(),
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

  // ─────────────────────────────────────────────
  // Top Bar
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  // Path Card
  // ─────────────────────────────────────────────
  Widget _buildCard(_PathItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.page),
        );
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
            // Icon circle
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFF1E2A3A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child:FaIcon(
                  item.icon,
                  color: Colors.white,
                  size: 26,
                )
              ),
            ),
            const SizedBox(height: 12),

            // Label
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

// ─────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────
class _PathItem {
  final String label;
  final FaIconData icon;
  final Widget page;  // ← أضف هذا

  _PathItem({
    required this.label,
    required this.icon,
    required this.page,
  });

}
