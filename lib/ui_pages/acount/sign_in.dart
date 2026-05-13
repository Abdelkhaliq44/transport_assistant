import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:transport_assistant/firebase/firebase_auth.dart';
import 'package:transport_assistant/ui_pages/home_page.dart';
class SignIn extends StatefulWidget {
  final VoidCallback? onGoToHome;
  const SignIn({super.key, this.onGoToHome});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _isPasswordVisible = false;
  TextEditingController _email =TextEditingController();
  TextEditingController _Password =TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Stack(
          children: [
            ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80.0,horizontal: 18),
                        child: Center(

                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage: AssetImage('assets/images/51b7a54fb46ffca4bc9e6e7c5324762cba3f9c83.jpg'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 25),
                        child: Center(
                          child: TextField(
                            controller: _email,
                            decoration: InputDecoration(
                              label: Text('Email'.tr()),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                              icon: Icon(Icons.email),
                              hintText: 'abdou50@gmail.comm',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 25),
                        child: Center(
                          child: TextField(
                            obscureText: !_isPasswordVisible,
                            controller: _Password,
                            decoration: InputDecoration(
                              label: Text('Password'.tr()),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                              icon: Icon(Icons.key),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible?Icons.visibility:Icons.visibility_off) ,
                                onPressed: (){
                                  setState(() {
                                    _isPasswordVisible =!_isPasswordVisible;
                                  });
                                },
                              ),

                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 3),
                        child: Center(
                          child:ElevatedButton(
                            onPressed: (){
                              AuthHelper().signIn(email: _email.text, password: _Password.text)
                                  .then((result){
                                if(result == null){
                                  widget.onGoToHome?.call(); // إخبار MyApp للرجوع للصفحة الرئيسية
                                  Navigator.of(context).pop();
                                }else{
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                                }

                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text('Sign in'.tr()),
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
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.clear),
              ),
            ),
          ]
      ),

    );
  }
}

// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:transport_assistant/firebase/firebase_auth.dart';
// import 'package:transport_assistant/ui_pages/home_page.dart';
// class SignIn extends StatefulWidget {
//   final VoidCallback? onGoToHome;
//   const SignIn({super.key, this.onGoToHome});
//
//   @override
//   State<SignIn> createState() => _SignInState();
// }
//
// class _SignInState extends State<SignIn> {
//   bool _isPasswordVisible = false;
//   TextEditingController _email =TextEditingController();
//   TextEditingController _Password =TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blueAccent,
//       body: Stack(
//         children: [
//           ListView(
//           children: [
//             Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 80.0,horizontal: 18),
//                 child: Center(
//
//                   child: CircleAvatar(
//                     radius: 80,
//                     backgroundImage: AssetImage('assets/images/acont_defalt.jpg'),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 25),
//                 child: Center(
//                   child: TextField(
//                     controller: _email,
//                     decoration: InputDecoration(
//                       label: Text('Email'.tr()),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
//                       icon: Icon(Icons.email),
//                       hintText: 'abdou50@gmail.comm',
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 25),
//                 child: Center(
//                   child: TextField(
//                     obscureText: !_isPasswordVisible,
//                     controller: _Password,
//                     decoration: InputDecoration(
//                       label: Text('Password'.tr()),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
//                       icon: Icon(Icons.key),
//                       suffixIcon: IconButton(
//                        icon: Icon(_isPasswordVisible?Icons.visibility:Icons.visibility_off) ,
//                         onPressed: (){
//                          setState(() {
//                            _isPasswordVisible =!_isPasswordVisible;
//                          });
//                         },
//                       ),
//
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 3),
//                 child: Center(
//                   child:ElevatedButton(
//                     onPressed: () async {
//                       var result = await AuthHelper().signIn(
//                         email: _email.text,
//                         password: _Password.text,
//                       );
//
//                       if (result == null) {
//                         User? user = FirebaseAuth.instance.currentUser;
//
//                         if (user != null) {
//                           await user.reload(); // تحديث الحالة من السيرفر
//                           user = FirebaseAuth.instance.currentUser;
//
//                           if (user!.emailVerified) {
//                             // ✅ الإيميل مؤكد → دخول
//                             widget.onGoToHome?.call();
//                             Navigator.of(context).pop();
//                           } else {
//                             // ❌ الإيميل غير مؤكد
//                             await FirebaseAuth.instance.signOut();
//
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Please verify your email before signing in.'.tr()),
//                               ),
//                             );
//                           }
//                         }
//                       } else {
//                         ScaffoldMessenger.of(context)
//                             .showSnackBar(SnackBar(content: Text(result)));
//                       }
//                     },
//
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                       child: Text('Sign in'.tr()),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.greenAccent
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ]
//         ),
//           Positioned(
//             top: 20,
//             right: 20,
//             child: IconButton(
//               onPressed: (){
//                 Navigator.of(context).pop();
//               },
//               icon: Icon(Icons.clear),
//             ),
//           ),
//     ]
//       ),
//
//     );
//   }
// }
