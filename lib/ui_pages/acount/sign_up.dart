import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transport_assistant/firebase/firebase_auth.dart';
import 'package:transport_assistant/ui_pages/acount/sign_in.dart';
class SignUp extends StatefulWidget {
  const SignUp({super.key});
  @override
  State<SignUp> createState() => _SignUpState();
}
class _SignUpState extends State<SignUp> {


  bool _isPasswordVisible = false;
  TextEditingController _email =TextEditingController();
  TextEditingController _Password =TextEditingController();
  TextEditingController _uesrname =TextEditingController();
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
                padding: const EdgeInsets.symmetric(vertical: 60.0,horizontal: 18),
                child: Center(

                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage('assets/images/acont_defalt.jpg'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 25),
                child: Center(
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
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
                    controller: _uesrname,
                    decoration: InputDecoration(
                      label: Text('Username'.tr()),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      icon: Icon(Icons.drive_file_rename_outline),
                      hintText: 'abdou59',
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
                      AuthHelper().signUp(email: _email.text, password: _Password.text, userName: _uesrname.text)
                          .then((result){
                            if(result == null){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>SignIn()));
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                            }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text('SignUp'.tr()),
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
