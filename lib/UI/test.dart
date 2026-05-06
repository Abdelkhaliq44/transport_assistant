
import 'package:flutter/material.dart';
import 'package:transport_assistant/UI/token.dart';

class Registration extends StatelessWidget {
  const Registration({super.key});

  @override
  Widget build(BuildContext context) {
    onButtonPress() {
      // Please sync "LoginScreen" to the project
    }

    return SafeArea(
        child: Scaffold(
            backgroundColor: Color(0xFFF0F4F3),

            body: SingleChildScrollView(
                child: Container(
                    color: whitesmoke,
                    width: double.infinity,
                    height: 932,
                    padding: const EdgeInsets.only(right: 27, bottom: 29),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Flex(
                          spacing: 65,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          direction: Axis.vertical,
                          children: [
                          Container(
                          width: 403,
                          height: 270,
                          padding: const EdgeInsets.only(right: 203),
                          alignment: AlignmentDirectional.topEnd,
                          child: const SizedBox(
                            width: 300,
                            height: 270,
                            child: Image(
                              image: AssetImage('assets/shape@2x.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                            width: width380,
                            height: 655,
                            child: Flex(
                                spacing: 73,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                direction: Axis.vertical,
                                children: [
                                Container(
                                width: 292,
                                height: 115,
                                padding: const EdgeInsets.only(right: 84, bottom: 17),
                                alignment: AlignmentDirectional.topEnd,
                                child: SizedBox(
                                    width: 208,
                                    height: 98,
                                    child: Flex(
                                      spacing: 31,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      direction: Axis.vertical,
                                      children: [
                                      const Text(
                                      'Welcome to Onboard! ',
                                      style: TextStyle(
                                        fontSize: fs18,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        height: 1.5,
                                        color: black200,
                                      ),
                                    ),
                                    Container(
                                        width: 208,
                                        height: 40,
                                        padding: const EdgeInsets.only(left: 1),
                                        alignment: AlignmentDirectional.topStart,
                                        child: const SizedBox(
                                            width: 207,
                                            child: Text(
                                              'Let’s help to meet up your tasks.',
                                              style: TextStyle(
                                                fontSize: fs13,
                                                fontFamily: 'Poppins',
                                                height: 1.57,
                                                letterSpacing: 0.666,
                                                color: black100,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                        ),
                                    ),
                                      ],
                                    ),
                                ),
                            ),
                            SizedBox(
                              width: width380,
                              height: 290,
                              child: Flex(
                                spacing: 30,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                direction: Axis.vertical,
                                children: [
                              TextField(
                              style: TextStyle(
                              fontSize: fs13,
                                fontFamily: 'Poppins',
                                color: black100,
                              ),
                              expands: true,
                              maxLines: null,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(br100),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(br100),
                                  ),
                                ),
                                fillColor: white,
                                filled: true,
                                hintStyle: TextStyle(
                                  fontSize: fs13,
                                  fontFamily: 'Poppins',
                                  color: black100,
                                ),
                                hintText: "Enter your full name",
                                contentPadding: EdgeInsets.only(
                                  top: 0,
                                  left: padding25,
                                  bottom: 0,
                                ),
                                constraints: BoxConstraints.expand(
                                  width: width380,
                                  height: 50,
                                ),
                              ),
                            ),
                            TextField(
                                style: TextStyle(
                                  fontSize: fs13,
                                  fontFamily: 'Poppins',
                                  color: black100,
                                ),
                                expands: true,
                                maxLines: null,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(br100),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(br100),
                                        ),
                                    ),
                                  fillColor: white,
                                  filled: true,
                                  hintStyle: TextStyle(
                                    fontSize: fs13,
                                    fontFamily: 'Poppins',
                                    color: black100,
                                  ),
                                  hintText: "Enter your Email",
                                  contentPadding: EdgeInsets.only(
                                    top: 0,
                                    left: padding25,
                                    bottom: 0,
                                  ),
                                  constraints: BoxConstraints.expand(
                                    width: width380,
                                    height: 50,
                                  ),
                                ),
                            ),
                            TextField(
                              style: TextStyle(
                                fontSize: fs13,
                                fontFamily: 'Poppins',
                                color: black100,
                              ),
                              expands: true,
                              maxLines: null,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(br100),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(br100),
                                  ),
                                ),
                                fillColor: white,
                                filled: true,
                                hintStyle: TextStyle(
                                  fontSize: fs13,
                                  fontFamily: 'Poppins',
                                  color: black100,
                                ),
                                hintText: "Enter Password",
                                contentPadding: EdgeInsets.only(
                                  top: 0,
                                  left: padding25,
                                  bottom: 0,
                                ),
                                constraints: BoxConstraints.expand(
                                  width: width380,
                                  height: 50,
                                ),
                              ),
                            ),
                            TextField(
                                style: TextStyle(
                                  fontSize: fs13,
                                  fontFamily: 'Poppins',
                                  color: black100,
                                ),
                                expands: true,
                                maxLines: null,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(br100),
                                        ),
                                    ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(br100),
                                    ),
                                  ),
                                  fillColor: white,
                                  filled: true,
                                  hintStyle: TextStyle(
                                    fontSize: fs13,
                                    fontFamily: 'Poppins',
                                    color: black100,
                                  ),
                                  hintText: "Confirm password",
                                  contentPadding: EdgeInsets.only(
                                    top: 0,
                                    left: padding25,
                                    bottom: 0,
                                  ),
                                  constraints: BoxConstraints.expand(
                                    width: width380,
                                    height: 50,
                                  ),
                                ),
                            ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: width380,
                              height: 104,
                              child: Flex(
                                spacing: 19,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                direction: Axis.vertical,
                                children: [
                              ElevatedButton(
                              child: Text(
                              "Register",
                                style: TextStyle(
                                  fontSize: fs18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  height: 1.57,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mediumturquoise,
                                foregroundColor: white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                padding: EdgeInsets.only(
                                  top: padding16,
                                  left: 149,
                                  right: 149,
                                  bottom: padding16,
                                ),
                                fixedSize: Size(width380, 60),
                                minimumSize: Size(380, 60),
                                elevation: 0,
                              ),
                              onPressed: onButtonPress,
                            ),
                            Container(
                                width: 326,
                                height: 25,
                                padding: const EdgeInsets.only(left: 54),
                                alignment: AlignmentDirectional.topStart,
                                child: RichText(
                                    textAlign: TextAlign.center,
                                    text: const TextSpan(
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          height: 1.57,
                                        ),
                                      children: [
                                        TextSpan(
                                          style: TextStyle(color: black200),
                                          text: 'Already have an account ? ',
                                        ),
                                        TextSpan(
                                          style: TextStyle(
                                            color: mediumturquoise,
                                          ),
                                          text: 'Sign In',
                                        ),
                                      ],
                                    ),
                                ),
                            ),
                                ],
                              ),
                            ),
                                ],
                            ),
                        ),
                          ],
                        ),
                    ),
                ),
            ),
        ),
    );
  }
}