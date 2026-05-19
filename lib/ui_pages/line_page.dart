import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:transport_assistant/ui_pages/acount/drwer_acount.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../line_type.dart';

class LinePage extends StatefulWidget {
  const LinePage({super.key, this.onGoToMap});
  final Function(LineType)? onGoToMap;

  @override
  State<LinePage> createState() => _LinePageState();
}

class _LinePageState extends State<LinePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loddelins();
      loddelinsFav();
      loadUserImage();
    });
  }

  String? imgpathe;
  List<List<String>> lines = [];
  List<List<String>> linesFav = [];

  loddelins() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('publicData')
        .doc('lines')
        .get();

    Map<String, dynamic> data = snapshot.data() ?? {};

    List<String> sortedKeys = data.keys.toList()
      ..sort((a, b) {
        int numA = int.tryParse(a.replaceAll('line', '')) ?? 0;
        int numB = int.tryParse(b.replaceAll('line', '')) ?? 0;
        return numA.compareTo(numB);
      });

    List<List<String>> loadedLines = sortedKeys
        .map((key) => (data[key] as List<dynamic>)
        .map((v) => v.toString())
        .toList())
        .toList();

    setState(() {
      lines = loadedLines;
    });
  }

  loddelinsFav() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    var snapshot = await FirebaseFirestore.instance
        .collection('linsFav')
        .doc(uid)
        .get();

    Map<String, dynamic> data = snapshot.data() ?? {};

    List<String> sortedKeys = data.keys.toList()
      ..sort((a, b) {
        int numA = int.tryParse(a.replaceAll('line', '')) ?? 0;
        int numB = int.tryParse(b.replaceAll('line', '')) ?? 0;
        return numA.compareTo(numB);
      });

    List<List<String>> loadedLines = sortedKeys
        .map((key) => (data[key] as List<dynamic>)
        .map((v) => v.toString())
        .toList())
        .toList();

    setState(() {
      linesFav = loadedLines;
    });
  }

  loadUserImage() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("users/$uid/profile.jpg");
      String url = await ref.getDownloadURL();
      setState(() {
        imgpathe = url;
      });
    } catch (e) {
      print("Error loading user image: $e");
    }
  }

  IconData getIcon(String type) {
    switch (type) {
      case 'bus':
        return Icons.directions_bus;
      case 'taxi':
        return Icons.local_taxi;
      case 'train':
        return Icons.train;
      default:
        return Icons.directions;
    }
  }

  void _toggleFavorite(List<String> line) async {
    final type = line[0];
    final name = line[1];
    final uid = FirebaseAuth.instance.currentUser!.uid;

    var docRef =
    FirebaseFirestore.instance.collection('linsFav').doc(uid);
    final data = await docRef.get();
    Map<String, dynamic> favData = data.data() ?? {};

    final existingKey = favData.keys.firstWhere(
          (k) => favData[k][0] == type && favData[k][1] == name,
      orElse: () => '',
    );

    if (existingKey != '') {
      favData.remove(existingKey);
    } else {
      final newKey = "line${favData.length + 1}";
      favData[newKey] = line;
    }

    await docRef.set(favData);
    setState(() {
      linesFav = favData.values
          .map((e) =>
          (e as List<dynamic>).map((v) => v.toString()).toList())
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.line_axis, color: Colors.white),
                text: 'lines'.tr(),
              ),
              Tab(
                icon: const Icon(Icons.favorite_outlined,
                    color: Colors.redAccent),
                text: 'favorite_line'.tr(),
              ),
            ],
          ),
          actions: [
            DropdownButton<String>(
              value: context.locale.languageCode,
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Row(
                    children: [
                      const Text('🇬🇧 ', style: TextStyle(fontSize: 20)),
                      Text('english'.tr()),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'ar',
                  child: Row(
                    children: [
                      const Text('🇸🇦 ', style: TextStyle(fontSize: 20)),
                      Text('arabic'.tr()),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'fr',
                  child: Row(
                    children: [
                      const Text('🇫🇷 ', style: TextStyle(fontSize: 20)),
                      Text('french'.tr()),
                    ],
                  ),
                ),
              ],
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  EasyLocalization.of(context)!
                      .setLocale(Locale(newValue));
                  setState(() {});
                }
              },
            ),
          ],
          toolbarHeight: 80,
          backgroundColor: const Color(0xfff4b7bff),
          centerTitle: true,
          title: Text(
            'transport_assistant'.tr(),
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: CircleAvatar(
                    backgroundImage: imgpathe != null
                        ? CachedNetworkImageProvider(imgpathe!)
                    as ImageProvider
                        : const AssetImage(
                        'assets/images/acont_defalt.jpg'),
                  ),
                ),
              );
            },
          ),
        ),
        drawer: const Drawer(child: DrwerAcount()),
        body: TabBarView(
          children: [
            // ── Tab 1: All Lines ──
            ListView.builder(
              padding:
              const EdgeInsets.fromLTRB(10.0, 10, 10.0, 5.0),
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final line = lines[index];
                final type = line[0];
                final name = line[1];
                final isFav = linesFav
                    .any((fav) => fav[0] == type && fav[1] == name);
                final color = Color(int.parse(line[2]));

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: color,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(getIcon(type),
                          color: Colors.red, size: 28),
                    ),
                    title: Text(
                      name.tr(),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      if (widget.onGoToMap != null) {
                        if (type == 'taxi') {
                          widget.onGoToMap!(LineType.taxi);
                        } else if (type == 'bus') {
                          widget.onGoToMap!(LineType.bus);
                        }
                      }
                    },
                    trailing: IconButton(
                      onPressed: () => _toggleFavorite(line),
                      icon: Icon(
                        isFav
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                        isFav ? Colors.redAccent : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── Tab 2: Favorite Lines ──
            linesFav.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'no_favorite_lines'.tr(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  10.0, 10, 10.0, 5.0),
              itemCount: linesFav.length,
              itemBuilder: (context, index) {
                final line = linesFav[index];
                final type = line[0];
                final name = line[1];
                final color = Color(int.parse(line[2]));

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: color,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(getIcon(type),
                          color: Colors.red, size: 28),
                    ),
                    title: Text(
                      name.tr(),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      if (widget.onGoToMap != null) {
                        if (type == 'taxi') {
                          widget.onGoToMap!(LineType.taxi);
                        } else if (type == 'bus') {
                          widget.onGoToMap!(LineType.bus);
                        }
                      }
                    },
                    trailing: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.red),
                        onPressed: () async {
                          final uid = FirebaseAuth
                              .instance.currentUser!.uid;
                          final docRef = FirebaseFirestore
                              .instance
                              .collection('linsFav')
                              .doc(uid);
                          var snapshot = await docRef.get();
                          Map<String, dynamic> favData =
                              snapshot.data() ?? {};
                          String keyToRemove =
                          favData.keys.elementAt(index);
                          favData.remove(keyToRemove);
                          await docRef.set(favData);
                          setState(() {
                            linesFav.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}