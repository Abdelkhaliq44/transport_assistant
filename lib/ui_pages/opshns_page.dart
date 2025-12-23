import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:transport_assistant/ui_pages/acount/drwer_acount.dart';

import 'package:transport_assistant/ui_pages/opshns_content/favorite_points.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'opshns_content/about.dart';
import 'opshns_content/register.dart';
import 'opshns_content/saved_points.dart';
import 'opshns_content/sittinges.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Optionspage extends StatefulWidget {
  final Function(double, double, String)? onGoToMap;
  final Function(bool)? onThemeChanged;
  final bool isDark;
  const Optionspage({super.key, this.onGoToMap, this.onThemeChanged, required this.isDark});

  @override
  State<Optionspage> createState() => _OptionspageState();
}

class _OptionspageState extends State<Optionspage> {
  String? imgpathe;

  @override
  void initState() {
    super.initState();
    loadUserImage();
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        toolbarHeight: 80,
        backgroundColor: Color(0xfff4b7bff),
        centerTitle: true,
        title: Text('transport_assistant'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white,),),
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
        ],leading: Builder(
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
      body: ListView(
        children:[
           Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0,70,18.0,18.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder:(context)=> fav_point(
                        onGoToMap:(lat, lng, name)async{
                          if (Navigator.canPop(context)) Navigator.pop(context);
                      if(widget.onGoToMap !=null){
                        widget.onGoToMap!(lat, lng, name);
                      }


                    })));
                  },
                  child: Card(
                    color: Color(0xffFFA726),
                    child:Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/images/fave.jpg'),
                          ),
                          SizedBox(width: 15.0,),
                           Text('favorites'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white,),),
                        ],
                      ),
                    ) ,
                  
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18,2,18,18),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder:(context)=> SavedPoints(
                        onGoToMap:(lat, lng, name)async{
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          if(widget.onGoToMap !=null){
                            widget.onGoToMap!(lat, lng, name);
                          }


                        })));
                  },
                  child: Card(
                    color: Color(0xffFFA726),
                    child:Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/images/save.png'),
                          ),
                          SizedBox(width: 15.0,),
                          Text('saved'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white,),),
                        ],
                      ),
                    ) ,
                  
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18,2,18,18),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Sittinges(
                          isDark: widget.isDark,
                          onThemeChanged: widget.onThemeChanged,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Color(0xffFFA726),
                    child:Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/images/sitng.jpg'),
                          ),
                          SizedBox(width: 15.0,),
                          Text('settings'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white,),),
                        ],
                      ),
                    ) ,
                  
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18,2,18,10),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder:(context)=> Register(
                        onGoToMap:(lat, lng, name)async{
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          if(widget.onGoToMap !=null){
                            widget.onGoToMap!(lat, lng, name);
                          }


                        })));
                  },
                  child: Card(
                    color: Color(0xffFFA726),
                    child:Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/images/hostr.jpg'),
                          ),
                          SizedBox(width: 15.0,),
                          Text('history'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white,),),
                        ],
                      ),
                    ) ,
                  
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18,2,18,10),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>About()));
                  },
                  child: Card(
                    color: Color(0xffFFA726),
                    child:Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            child: Icon(Icons.info_outline),
                          ),
                          SizedBox(width: 15.0,),
                          Text('about'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white,),),
                        ],
                      ),
                    ) ,

                  ),
                ),
              ),
            ],
        ),
        ],
      ),
      
    );
  }
}
