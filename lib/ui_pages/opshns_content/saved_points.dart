import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transport_assistant/Data/saved_pints.dart';
import 'package:transport_assistant/ui_pages/acount/sign_in.dart';

class SavedPoints extends StatefulWidget {
  final Function(double lat, double lng, String name)? onGoToMap;
  const SavedPoints({super.key, this.onGoToMap});

  @override
  State<SavedPoints> createState() => SavedPointsState();
}

class SavedPointsState extends State<SavedPoints> {
  int _selectedIndex = -1;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _isLoggedIn = user != null;
    if (_isLoggedIn) {
      loddeSavepoint();
    } else {
      setState(() => _isLoading = false);
    }
  }

  loddeSavepoint() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    var snapshot = await FirebaseFirestore.instance
        .collection('Savepoint')
        .doc(uid)
        .get();

    Map<String, dynamic> data = snapshot.data() ?? {};

    List<String> sortedKeys = data.keys.toList()
      ..sort((a, b) {
        int numA = int.tryParse(a.replaceAll('point', '')) ?? 0;
        int numB = int.tryParse(b.replaceAll('point', '')) ?? 0;
        return numA.compareTo(numB);
      });

    List<List<String>> loadedLines = sortedKeys
        .map((key) => (data[key] as List<dynamic>)
        .map((v) => v.toString())
        .toList())
        .toList();

    setState(() {
      pointSaved = loadedLines;
      _isLoading = false;
    });
  }

  Future<void> _deletePoint(int index) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection('Savepoint').doc(uid);
    final snapshot = await docRef.get();
    Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.data() ?? {});

    List<String> sortedKeys = data.keys.toList()
      ..sort((a, b) {
        int numA = int.tryParse(a.replaceAll('point', '')) ?? 0;
        int numB = int.tryParse(b.replaceAll('point', '')) ?? 0;
        return numA.compareTo(numB);
      });

    final keyToDelete = sortedKeys[index];
    data.remove(keyToDelete);

    Map<String, dynamic> reindexed = {};
    int i = 1;
    for (final key in (data.keys.toList()
      ..sort((a, b) {
        int numA = int.tryParse(a.replaceAll('point', '')) ?? 0;
        int numB = int.tryParse(b.replaceAll('point', '')) ?? 0;
        return numA.compareTo(numB);
      }))) {
      reindexed['point$i'] = data[key];
      i++;
    }

    await docRef.set(reindexed);

    setState(() {
      pointSaved.removeAt(index);
      if (_selectedIndex == index) {
        _selectedIndex = -1;
      } else if (_selectedIndex > index) {
        _selectedIndex--;
      }
    });
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C2B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('delete_point_title'.tr(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'delete_point_confirm'.tr(args: [pointSaved[index][0], 'saved_label'.tr()]),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr(), style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePoint(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('delete_success_saved'.tr())),
              );
            },
            child: Text('delete'.tr(), style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
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

  // ── Saved Card ──
  Widget _buildSavedCard(List<String> line, int index) {
    final name = line[0];
    final isSelected = _selectedIndex == index;

    return Dismissible(
      key: ValueKey('$name-$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        bool confirmed = false;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1C2B3A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('delete_point_title'.tr(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Text(
              'delete_point_confirm'.tr(args: [name, 'saved_label'.tr()]),
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () { confirmed = false; Navigator.pop(context); },
                child: Text('cancel'.tr(), style: const TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () { confirmed = true; Navigator.pop(context); },
                child: Text('delete'.tr(), style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
        return confirmed;
      },
      onDismissed: (_) async {
        await _deletePoint(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('delete_success_named'.tr(args: [name, 'saved_label'.tr()]))),
        );
      },
      child: GestureDetector(
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
              GestureDetector(
                onTap: () => _confirmDelete(index),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 17),
                ),
              ),
            ],
          ),
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
          Icon(Icons.bookmark_border_rounded, size: 72, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('no_saved_points'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 8),
          Text('no_saved_points_desc'.tr(),
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
              child: const Icon(Icons.bookmark_border, size: 40, color: Color(0xFFBECFDF)),
            ),
            const SizedBox(height: 24),
            const Text(
              "You don't have an account",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Sign in to view your saved points',
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
                Text('saved'.tr(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : !_isLoggedIn
                      ? _buildNotLoggedInContent()
                      : pointSaved.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pointSaved.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _buildSavedCard(pointSaved[index], index),
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