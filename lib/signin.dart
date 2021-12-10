import 'dart:async';
import 'package:citi_police/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io' as IO;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:citi_police/app_constants.dart';
import 'package:citi_police/signin.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home.dart';

late SharedPreferences prefs;

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController phoneController = TextEditingController(text: "+91");
  TextEditingController otpController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  bool otpVisibility = false;

  String verificationID = "", deviceToken="";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 20),
            child: Container(
              height: 150.0,
              width: 200.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  image: const DecorationImage(
                      image: AssetImage(
                        "assets/images/login.jpeg",
                      ),
                      fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          const Text(
            'Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            keyboardType: TextInputType.phone,
            controller: phoneController,
            style: TextStyle(color: textColor),
            onChanged: (textValue) {
              setState(() {});
            },
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: PRIMARY_COLOR, width: 2.0)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFCCCCCC)),
              ),
              labelText: 'Mobile number',
              labelStyle: TextStyle(color: textColor),
            ),
          ),
          Visibility(child: Container(
            margin: EdgeInsets.only(top: 10),
            child: TextField(
              controller: otpController,
              decoration: InputDecoration(
                  hintText: "Enter OTP here..."
              ),
              keyboardType: TextInputType.number,
            ),
          ),visible: otpVisibility,),
          SizedBox(height: 20,),
          isLoading ? Center(child: CircularProgressIndicator(color: PRIMARY_COLOR,),) : TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => PRIMARY_COLOR,
                ),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                )),
              ),
              onPressed: () {
                if (phoneController.text.isEmpty) {
                  Fluttertoast.showToast(msg: "Enter Mobile no.");
                } else if (!phoneController.text.contains("+91")) {
                  Fluttertoast.showToast(msg: "Please add country code, ex. +91");
                } else {
                  if (otpVisibility) {
                    setState(() {
                      isLoading = true;
                    });
                    verifyOTP();
                  }
                  else {
                    setState(() {
                      isLoading = true;
                    });
                    loginWithPhone();
                  }
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: Text(otpVisibility ? "Verify" : "Login",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              )),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignupPage()));
              },
              child: Wrap(
                children: const [
                  Text(
                    'Not have an account? ',
                  ),
                  Text(
                    'Create one',
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void loginWithPhone() async {
    auth.verifyPhoneNumber(
      phoneNumber: phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value){
          print("You are logged in successfully");
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        otpVisibility = true;
        verificationID = verificationId;
        isLoading=false;
        setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {

      },
    );
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void verifyOTP() async {
    await SignInPage.init();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationID, smsCode: otpController.text);

    await auth.signInWithCredential(credential).then((value) async {
      prefs.setString("isLoggedIn", "1");
      await _firebaseMessaging.getToken().then((token) async {
        assert(token != null);
        print("Firebase token: " + token!);
        deviceToken = token;
      });
      Fluttertoast.showToast(
          msg: "You are logged in successfully",
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0
      );
      await FirebaseFirestore.instance
          .collection("Users").doc(auth.currentUser!.uid)
          .update({"token": deviceToken});
      setState(() {
        isLoading=false;
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
      const Home()));
    });
  }
}
