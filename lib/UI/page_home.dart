import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transport_assistant/UI/favorites_point.dart';
import 'package:transport_assistant/UI/historique.dart';
import 'package:transport_assistant/UI/saved_point.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}
int _selectedOptionIndex = -1;

class _MapScreenState extends State<MapScreen> {
  bool _showSearch = false;
  bool _showGetLine = false;
  bool _showMapPicker = false;
  bool _showLocationCard = false;
  bool _isSaved = false;
  bool _isFavorite = false;


  final List<FaIconData> _transportIcons = [
    FontAwesomeIcons.taxi,
    FontAwesomeIcons.bus,
    FontAwesomeIcons.train,
    FontAwesomeIcons.trainTram,
    FontAwesomeIcons.trainSubway,
    FontAwesomeIcons.cableCar,
  ];
  final List<Widget> _optionPages = [
    SavedPointsScreen(),
   // HistoryScreen(),
    FavoritesScreen(),
  ];
  int _selectedTransport = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowLocationAlert();
    });
  }

  Future<void> _checkAndShowLocationAlert() async {
    final status = await Permission.location.status;
    if (!status.isGranted) {
      _showLocationPermissionAlert();
    }
  }
  void _showOptionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF1C2B3A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: IndexedStack(
            index: _selectedOptionIndex,
            children: _optionPages,
          ),
        );
      },
    );
  }
  void _showLocationPermissionAlert() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C2B3A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 36),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3E4B),
                  shape: BoxShape.circle,
                  border:
                  Border.all(color: const Color(0xFF3A4F65), width: 1.5),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFFCDD9E5),
                  size: 34,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Allow Your Location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Enable your location to see transport\noptions near you',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _requestLocationPermission();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCDD9E5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Turn On',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C2B3A),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Not Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        debugPrint('Location: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        debugPrint('Error getting location: $e');
      }
    }
  }

  void _showRouteAlert() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      isScrollControlled: true,
      builder: (ctx) => _RouteBottomSheet(
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Build — بدون bottom nav
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2535),
      body: Stack(
        children: [
          // ── Map image ──
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (!_showSearch && !_showGetLine && !_showMapPicker) {
                  setState(() => _showLocationCard = true);
                }
              },
              child: Image.asset(
                'assets/images/iPhone 14 & 15 Pro - 32.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          if (_showMapPicker) ...[
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => setState(() => _showMapPicker = false),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E3E4B).withOpacity(0.85),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () =>
                            setState(() => _showMapPicker = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E3E4B),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Set',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SafeArea(
              child: Column(
                children: [
                  _buildActivePanel(),
                  Expanded(
                    child: Stack(
                      children: [
                        if (!_showLocationCard)
                          Positioned(
                            right: 12,
                            top: 350,
                            child: Column(
                              children: List.generate(
                                _transportIcons.length,
                                    (i) => _buildTransportButton(i),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_showLocationCard) _buildLocationCard(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1C2B3A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black45, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'International Conference Center\nAbdelatif Rahal',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  'Route De Cheraga, Ain Benian, Algeries,\nAlgeria',
                  style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              _cardIconButton(
                icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                isActive: _isSaved,
                onTap: () => setState(() => _isSaved = !_isSaved),
              ),
              const SizedBox(width: 8),
              _cardIconButton(
                icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                isActive: _isFavorite,
                onTap: () => setState(() => _isFavorite = !_isFavorite),
              ),
              const SizedBox(width: 8),
              _cardIconButton(
                icon: Icons.close,
                onTap: () => setState(() => _showLocationCard = false),
                isClose: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isClose = false,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isClose
              ? const Color(0xFFE57373).withOpacity(0.85)
              : isActive
              ? Colors.white
              : const Color(0xFF2E3E4B),
          shape: BoxShape.circle,
          border: isClose
              ? null
              : Border.all(
              color: isActive ? Colors.white : const Color(0xFF3A4F65),
              width: 1),
        ),
        child: Icon(icon,
            color: isClose
                ? Colors.white
                : isActive
                ? const Color(0xFF1C2B3A)
                : Colors.white,
            size: 17),
      ),
    );
  }

  Widget _buildActivePanel() {
    if (_showGetLine) return _buildGetLinePanel();
    if (_showSearch) return _buildSearchPanel();
    return _buildTopBar();
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Image.asset(
              'assets/images/67460f18808338f4f4b8dd938dff42beca7021c8.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _showSearch = true;
                _showLocationCard = false;
              }),
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
                      child: Text('Choose your destination',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(Icons.search,
                          color: Colors.grey.shade600, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPanel() {
    return _panelContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                  child: _searchField(
                      hint: 'Search a destination', autofocus: true)),
              const SizedBox(width: 8),
              _closeButton(
                  onTap: () => setState(() => _showSearch = false)),
            ],
          ),
          const SizedBox(height: 14),
          if (_showSearch || _showGetLine)
            Row(
              children: [
                _optionButton(
                    icon: Icons.bookmark_border,
                    label: 'Saved\nPlaces',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedPointsScreen(),
                        ),
                      );
                    }),
                const SizedBox(width: 10),
                _optionButton(
                    icon: Icons.history,
                    label: 'History\nPlaces',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryPlacesPage(),
                        ),
                      );
                    }),
                const SizedBox(width: 10),
                _optionButton(
                    icon: Icons.favorite_border,
                    label: 'Favorites\nPlaces',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FavoritesScreen(),
                        ),
                      );
                    }),
              ],
            ),
          const SizedBox(height: 14),
          _primaryButton(
            icon: Icons.sync_alt,
            label: 'Choose Start/End points',
            onPressed: () => setState(() {
              _showSearch = false;
              _showGetLine = true;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGetLinePanel() {
    return _panelContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  _showGetLine = false;
                  _showSearch = true;
                }),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 26),
              ),
              const Spacer(),
              _closeButton(
                  onTap: () => setState(() => _showGetLine = false)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _dot(filled: false),
                  Container(
                    width: 1.5,
                    height: 48,
                    color: Colors.white38,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                  ),
                  _dot(filled: true),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _searchField(
                                hint: 'Current position',
                                autofocus: false)),
                        const SizedBox(width: 8),
                        _swapButton(),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      children: [
                        Expanded(
                            child: _searchField(
                                hint: 'Choose a destination',
                                autofocus: false)),
                        const SizedBox(width: 8),
                        _swapButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _showRouteAlert,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBECFDF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23)),
              ),
              child: const Text('Get Line',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3E4B))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3E4B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }

  Widget _searchField({required String hint, required bool autofocus}) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2E3E4B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBECFDF), width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              autofocus: autofocus,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                TextStyle(color: Colors.grey.shade500, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(Icons.search,
                color: Colors.grey.shade400, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _closeButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            color: Colors.grey.shade600, shape: BoxShape.circle),
        child: const Icon(Icons.close, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _optionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFBECFDF).withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBECFDF), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white70, size: 11),
            ],
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBECFDF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFF3A4F65), width: 1),
          ),
        ),
        icon: Icon(icon, size: 18, color: const Color(0xFF2E3E4B)),
        label: Text(label,
            style: const TextStyle(
                color: Color(0xFF2E3E4B),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _dot({required bool filled}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        color: filled ? Colors.white : Colors.transparent,
      ),
      child: filled
          ? Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
              color: Color(0xFF2A3A4E), shape: BoxShape.circle),
        ),
      )
          : null,
    );
  }

  Widget _swapButton() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3A4F65)),
      ),
      child: IconButton(
        onPressed: () => setState(() => _showMapPicker = true),
        icon:
        const Icon(Icons.map_outlined, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildTransportButton(int index) {
    final selected = index == _selectedTransport;
    return GestureDetector(
      onTap: () => setState(() => _selectedTransport = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.88)
              : const Color(0xFF2E3E4B),
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: const Color(0xFF2E3E4B), width: 2)
              : null,
        ),
        child: Center(  // ← أضف هذا
          child: FaIcon(
            _transportIcons[index],
            color: selected ? const Color(0xFF2E3E4B) : Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Route Bottom Sheet
// ─────────────────────────────────────────────
class _RouteBottomSheet extends StatefulWidget {
  final VoidCallback onClose;
  const _RouteBottomSheet({required this.onClose});

  @override
  State<_RouteBottomSheet> createState() => _RouteBottomSheetState();
}

class _RouteBottomSheetState extends State<_RouteBottomSheet> {
  bool _isSaved = false;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C2B3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70, width: 2.2),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('International Conference Center',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Text('Abdelatif Rahal',
                        style:
                        TextStyle(color: Colors.white60, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _iconBtn(_isSaved ? Icons.bookmark : Icons.bookmark_border,
                  isActive: _isSaved,
                  onTap: () => setState(() => _isSaved = !_isSaved)),
              const SizedBox(width: 6),
              _iconBtn(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  isActive: _isFavorite,
                  onTap: () =>
                      setState(() => _isFavorite = !_isFavorite)),
              const SizedBox(width: 6),
              _iconBtn(Icons.close,
                  onTap: widget.onClose, isClose: true),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 9, top: 5, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                  5,
                      (_) => Container(
                    width: 2,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(1)),
                  )),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.location_on,
                  color: Colors.white70, size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Huawei Algeria, Bab Ezzouar',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon,
      {required VoidCallback onTap,
        bool isClose = false,
        bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isClose
              ? const Color(0xFFE57373).withOpacity(0.9)
              : isActive
              ? Colors.white
              : const Color(0xFF2E3E4B),
          shape: BoxShape.circle,
          border: isClose
              ? null
              : Border.all(
              color: isActive ? Colors.white : const Color(0xFF3A4F65),
              width: 1),
        ),
        child: Icon(icon,
            color: isClose
                ? Colors.white
                : isActive
                ? const Color(0xFF1C2B3A)
                : Colors.white,
            size: 16),
      ),
    );
  }
}