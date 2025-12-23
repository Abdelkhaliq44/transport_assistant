import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:transport_assistant/ui_pages/acount/drwer_acount.dart';
import 'package:cached_network_image/cached_network_image.dart';
class LinePage extends StatefulWidget {
  const LinePage({super.key, this.onGoToMap});
  final VoidCallback? onGoToMap;
  @override
  State<LinePage> createState() => _LinePageState();
}

class _LinePageState extends State<LinePage> {





  @override
  void initState() {
    super.initState();
    loadUserImage();
    loddelins();
    loddelinsFav();
  }
  String? imgpathe;
  List<List<String>> lines = [];
  List<List<String>> linesFav = [];
  loddelins()async{

    var snapshot = await FirebaseFirestore.instance
        .collection('publicData')
        .doc('lines')
        .get();

    Map<String, dynamic> data = snapshot.data() ?? {};

// تحويل كل field إلى List داخل List
    List<String> sortedKeys = data.keys.toList()
      ..sort((a, b) {
        // استخراج الرقم من المفتاح
        int numA = int.tryParse(a.replaceAll('line', '')) ?? 0;
        int numB = int.tryParse(b.replaceAll('line', '')) ?? 0;
        return numA.compareTo(numB);
      });

    // تحويل البيانات المرتبة إلى List
    List<List<String>> loadedLines = sortedKeys
        .map((key) => (data[key] as List<dynamic>)
        .map((v) => v.toString())
        .toList())
        .toList();
    setState(() {
      lines = loadedLines; // تحديث الحالة
    });

  }
  loddelinsFav()async{
    final uid = FirebaseAuth.instance.currentUser!.uid;

    var snapshot = await FirebaseFirestore.instance
        .collection('linsFav')
        .doc(uid)
        .get();

    Map<String, dynamic> data = snapshot.data() ?? {};

// تحويل كل field إلى List داخل List
    List<String> sortedKeys = data.keys.toList()
      ..sort((a, b) {
        // استخراج الرقم من المفتاح
        int numA = int.tryParse(a.replaceAll('line', '')) ?? 0;
        int numB = int.tryParse(b.replaceAll('line', '')) ?? 0;
        return numA.compareTo(numB);
      });

    // تحويل البيانات المرتبة إلى List
    List<List<String>> loadedLines = sortedKeys
        .map((key) => (data[key] as List<dynamic>)
        .map((v) => v.toString())
        .toList())
        .toList();
    setState(() {
      linesFav = loadedLines; // تحديث الحالة
    });

  }
  loadUserImage() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      Reference ref = FirebaseStorage.instance.ref().child("users/$uid/profile.jpg");
      String url = await ref.getDownloadURL();  // الرابط مباشرة من Storage
      setState(() {
        imgpathe = url;
      });
    } catch (e) {
      print("Error loading user image: $e");
    }
  }
  IconData  getIcon (String type){

    switch(type){
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

  void _toMap (){
   if (widget.onGoToMap != null){
     widget.onGoToMap! ();
   }
  }
  void _toggleFavorite (List<String> line) async
  {
    final type = line[0];
    final name = line[1];
    final uid = FirebaseAuth.instance.currentUser!.uid;

    var docRef = await FirebaseFirestore.instance
        .collection('linsFav')
        .doc(uid);
    final data = await docRef.get();
    Map<String, dynamic> favData = data.data() ?? {};
    final existingKey = favData.keys.firstWhere(
          (k) => favData[k][0] == type && favData[k][1] == name,
      orElse: () => '',
    );

    if (existingKey != '') {
      // حذف المفضلة
      favData.remove(existingKey);
    } else {
      // إضافة مفضلة جديدة
      final newKey = "line${favData.length + 1}";
      favData[newKey] = line;
    }
    await docRef.set(favData);
    setState(() {
      linesFav = favData.values
          .map((e) => (e as List<dynamic>).map((v) => v.toString()).toList())
          .toList();
    });


  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar:AppBar(
          bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.line_axis,color: Colors.white,), text: 'lines'.tr()),
                Tab(icon: Icon(Icons.favorite_outlined,color: Colors.redAccent,), text: 'favorite_line'.tr(),),
              ],
          ),
          actions: [
            DropdownButton(
              value: context.locale.languageCode,
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Row(
                    children: [
                      Text('🇬🇧 ', style: TextStyle(fontSize: 20)),
                      Text('English'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'ar',
                  child: Row(
                    children: [
                      Text('🇸🇦 ', style: TextStyle(fontSize: 20)),
                      Text('العربية'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'fr',
                  child: Row(
                    children: [
                      Text('🇫🇷 ', style: TextStyle(fontSize: 20)),
                      Text('Français'),
                    ],
                  ),
                ),
              ],
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  EasyLocalization.of(context)!.setLocale(Locale(newValue));// تغيير اللغة
                  setState(() {});
                }
              },
            ),
          ],
          toolbarHeight: 80,
          backgroundColor: Color(0xfff4b7bff),
          centerTitle: true,
          title: Text('transport_assistant'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white,),),
          leading: Builder(
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: (){
                      Scaffold.of(context).openDrawer();
                    },
                    child: CircleAvatar(
                      backgroundImage: imgpathe != null
                          ? CachedNetworkImageProvider(imgpathe!)
                          : AssetImage('assets/images/acont_defalt.jpg') as ImageProvider,
                    ),
                  ),
                );
              }
          ),
        ),
        drawer: Drawer(
          child: DrwerAcount(),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
                padding: const EdgeInsets.fromLTRB(10.0,10,10.0,5.0),
                itemCount: lines.length,
                itemBuilder: (context,index){

                  final line = lines[index];
                  final type = line[0];
                  final name = line[1];
                  final isFav = linesFav.any((fav) => fav[0] == type && fav[1] == name);
                  final color =Color(int.parse(line[2])) ;
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: color,
                    child:ListTile(

                          leading:  CircleAvatar(
                             child: Icon(getIcon(type), color: Colors.red, size: 28),
                           ),
                          title:  Text(name.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white,),),
                          onTap: _toMap,
                          trailing: IconButton(
                              onPressed: () => _toggleFavorite(line),
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.redAccent : Colors.white,
                              ),
                          ),
                    ) ,

                  );
                },


            ),
            linesFav.isEmpty
                  ?
                 Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text('no_favorite_lines'.tr(), style: TextStyle(fontSize: 20))),
                ) : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(10.0,10,10.0,5.0),
                  itemCount: linesFav.length,
                  itemBuilder: (context,index){
                    final line = linesFav[index];
                    final type = line[0];
                    final name = line[1];
                    final color =Color(int.parse(line[2])) ;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: color,
                      child:ListTile(

                        leading:  CircleAvatar(
                          child: Icon(getIcon(type), color: Colors.red, size: 28),
                        ),
                        title:  Text(name.tr(), style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white,),),
                        onTap: _toMap,
                        trailing: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(

                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async{
                              final docRef = FirebaseFirestore.instance
                                  .collection('publicData')
                                  .doc('linesFav');
                              var snapshot = await docRef.get();
                              Map<String, dynamic> favData = snapshot.data() ?? {};
                              String keyToRemove = favData.keys.elementAt(index);
                              favData.remove(keyToRemove);
                              await docRef.set(favData);
                              setState(() {
                                linesFav.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ) ,

                    );
                  },


                ),

          ]
        ),
      ),
    );
  }
}
