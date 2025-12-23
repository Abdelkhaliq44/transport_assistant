import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transport_assistant/firebase/firebase_auth.dart';
import 'package:transport_assistant/ui_pages/acount/sign_in.dart';
import 'package:transport_assistant/ui_pages/acount/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
class DrwerAcount extends StatefulWidget {
  final VoidCallback? onGoToHome;
  const DrwerAcount({super.key, this.onGoToHome});

  @override
  State<DrwerAcount> createState() => _DrwerAcountState();
}

class _DrwerAcountState extends State<DrwerAcount> {
  Future<String> uploadImageToStorage(String filePath) async {
    File file = File(filePath);

    String uid = FirebaseAuth.instance.currentUser!.uid;
    Reference ref = FirebaseStorage.instance.ref().child("users/$uid/profile.jpg");

    await ref.putFile(file);

    // الحصول على رابط الصورة
    String url = await ref.getDownloadURL();
    return url;
  }
  String? imgpathe;
  User? user;
  String? email;
  String? name;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginState();
    loadUserData();
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


  void loadUserData() {
    user = FirebaseAuth.instance.currentUser;
    email = user?.email;
    name = user?.displayName;
  }

  void checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('logged_in') ?? false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: !isLoggedIn ?ListView(
        children: [
          Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 80.0,horizontal: 18),
              child: Center(

                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage('assets/images/acont_defalt.jpg'),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 3),
              child: Center(
                child:ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SignIn()));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal:30),
                    child: Text('Sign in'.tr(),style: TextStyle(fontSize: 20),),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent
                  ),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 10,horizontal: 1),
              child: ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUp()));
                },
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 10,horizontal: 30),
                  child: Text('SignUp'.tr(),style: TextStyle(fontSize: 20),),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 20,horizontal: 1),
              child: ElevatedButton(
                onPressed: ()async{
                  final authHelper = AuthHelper();
                  final user = await authHelper.signInWithGoogle();
                    if (user != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تسجيل الدخول: ${user.displayName}'), ));
                    }else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل تسجيل الدخول"), ));
                    }
                },
                child: Text('Connect with Google'.tr()),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent
                ),
              ),
            ),
          ],
        ),
      ]
      ):ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80.0,horizontal: 18),
                  child: Center(

                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 100,
                          backgroundImage: imgpathe != null
                              ? CachedNetworkImageProvider(imgpathe!)
                              : AssetImage('assets/images/acont_defalt.jpg') as ImageProvider,
                        ),
                        Positioned(
                          bottom: 5,
                          left: 5,
                          child: CircleAvatar(
                            child: IconButton(
                                onPressed: () async {
                                  final picre = ImagePicker();
                                  final picred = await picre.pickImage(source: ImageSource.gallery);
                                  if (picred != null) {
                                    String imageUrl = await uploadImageToStorage(picred.path);
                                    print("Uploaded Image URL: $imageUrl");
                                    setState(() {
                                      imgpathe = imageUrl;
                                    });
                                  }
                                },
                                icon: Icon(Icons.add)
                            ),
                          ),
                        ),

                    ]
                    ),
                  ),
                ),
                Text(
                  name?? "No Name",
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                SizedBox(height: 10,),
                Text(
                 email ?? "No Email",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 3),
                  child: Center(
                    child:ElevatedButton(
                      onPressed: (){
                        AuthHelper().signOut();
                        widget.onGoToHome?.call(); // إخبار MyApp للرجوع للصفحة الرئيسية
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: EdgeInsetsGeometry.symmetric(vertical: 10,horizontal:30),
                        child: Text('SignOut'.tr(),style: TextStyle(fontSize: 20),),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ]
      ),
    );
  }
}
