import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transport_assistant/Data/saved_pints.dart';
class SavedPoints extends StatefulWidget {
  final Function(double lat, double lng, String name)? onGoToMap;
  const SavedPoints({super.key, this.onGoToMap});

  @override
  State<SavedPoints> createState() => SavedPointsState();
}

class SavedPointsState extends State<SavedPoints> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loddeSavepoint();
  }
  loddeSavepoint()async{
    final uid = FirebaseAuth.instance.currentUser!.uid;

    var snapshot = await FirebaseFirestore.instance
        .collection('Savepoint')
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
      pointSaved = loadedLines; // تحديث الحالة
    });

  }
  void _toMap (double lat, double lng, String name){
    if (widget.onGoToMap != null){
      widget.onGoToMap! (lat, lng, name);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Color(0xfff4b7bff),
        toolbarHeight: 80,
        centerTitle: true,
        title: Text('saved'.tr(),style: TextStyle(fontSize: 30,),),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(10.0,10,10.0,5.0),
        itemCount: pointSaved.length,
        itemBuilder: (context,index){

          final line = pointSaved[index];
          final name = line[0];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Colors.red,
            child:ListTile(

              leading:  CircleAvatar(
                child: Icon(Icons.place_outlined, color: Colors.red, size: 28),
              ),
              title:  Text(name.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white,),),
              onTap: (){
                final lat = double.tryParse(line[1].toString().replaceAll(',', '.')) ?? 0.0;
                final lng = double.tryParse(line[2].toString().replaceAll(',', '.')) ?? 0.0;

                _toMap(lat, lng, name);
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ) ,

          );
        },


      ),
    );
  }
}
