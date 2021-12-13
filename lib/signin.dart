import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';
import 'home.dart';

late SharedPreferences prefs;

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  _SigninPageState createState() => _SigninPageState();

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }
}

class _SigninPageState extends State<SigninPage> {
  TextEditingController phoneController = TextEditingController(text: "+91");
  TextEditingController passController = TextEditingController();

  bool _obscureText = true;
  IconData _iconVisible = Icons.visibility_off;

  // TextEditingController otpController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  bool otpVisibility = false, isLoading = false;

  // String verificationID = "";

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
      if (_obscureText == true) {
        _iconVisible = Icons.visibility_off;
      } else {
        _iconVisible = Icons.visibility;
      }
    });
  }

  String deviceToken = "";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future login() async {
    await SigninPage.init();
    await _firebaseMessaging.getToken().then((token) async {
      assert(token != null);
      print("Firebase token: " + token!);
      deviceToken = token;
    });
    await FirebaseFirestore.instance
        .collection("Cops")
        .doc(phoneController.text)
        .set({"token": deviceToken, "mobile": phoneController.text, "lat": "0", "long": "0"});
    setState(() {
      isLoading = false;
    });
    Fluttertoast.showToast(
        msg: "You are logged in successfully",
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0);
  }

  // final formKey = GlobalKey<FormState>();
  // StreamController<ErrorAnimationType>? errorController;
  // bool hasError = false;
  // String currentText = "";

  // Future<void> showOTPDialog(context) {
  //   return showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Padding(
  //         padding: EdgeInsets.only(left: 24.0, right: 24.0),
  //         child: AlertDialog(
  //           contentPadding: EdgeInsets.zero,
  //           insetPadding: EdgeInsets.zero,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           title: Text(
  //             'Verify OTP',
  //             textAlign: TextAlign.center,
  //             style: TextStyle(fontSize: 18, color: PRIMARY_COLOR, fontWeight: FontWeight.bold),
  //           ),
  //           content: SingleChildScrollView(
  //             child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Container(
  //                           margin: EdgeInsets.only(top: 8.0),
  //                           padding: EdgeInsets.all(4.0),
  //                           width: MediaQuery.of(context).size.width,
  //                           child: Text('OTP Code has been sent to your mobile number',
  //                             style: TextStyle(fontSize: 13, color: Colors.white,), textAlign: TextAlign.center,),
  //                           color: PRIMARY_COLOR,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 8.0,),
  //                   Container(child: Text('Enter OTP here...',
  //                       style: TextStyle(color: PRIMARY_COLOR))
  //                   ),
  //                   Form(
  //                     key: formKey,
  //                     child: Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                             vertical: 8.0, horizontal: 50),
  //                         child: PinCodeTextField(
  //                           appContext: context,
  //                           pastedTextStyle: TextStyle(
  //                             // color: Colors.green.shade600,
  //                             // fontWeight: FontWeight.bold,
  //                           ),
  //                           length: 4,
  //                           // obscureText: true,
  //                           // obscuringCharacter: '*',
  //                           // obscuringWidget: FlutterLogo(
  //                           //   size: 24,
  //                           // ),
  //                           blinkWhenObscuring: true,
  //                           animationType: AnimationType.fade,
  //                           // validator: (v) {
  //                           //   if (v!.length < 4) {
  //                           //     return "Invalid OTP Code";
  //                           //   } else {
  //                           //     return null;
  //                           //   }
  //                           // },
  //                           pinTheme: PinTheme(
  //                               shape: PinCodeFieldShape.box,
  //                               borderRadius: BorderRadius.circular(5),
  //                               fieldHeight: 50,
  //                               fieldWidth: 40,
  //                               activeFillColor: Colors.white,
  //                               inactiveFillColor: Colors.white,
  //                               selectedFillColor: Colors.white
  //                           ),
  //                           cursorColor: PRIMARY_COLOR,
  //                           animationDuration: Duration(milliseconds: 300),
  //                           enableActiveFill: true,
  //                           // errorAnimationController: errorController,
  //                           // controller: textEditingController,
  //                           keyboardType: TextInputType.number,
  //                           boxShadows: [
  //                             BoxShadow(
  //                               offset: Offset(0, 1),
  //                               color: Colors.black12,
  //                               blurRadius: 10,
  //                             )
  //                           ],
  //                           onCompleted: (v) {
  //                             print("Completed");
  //                           },
  //                           // onTap: () {
  //                           //   print("Pressed");
  //                           // },
  //                           onChanged: (value) {
  //                             print(value);
  //                             setState(() {
  //                               currentText = value;
  //                             });
  //                           },
  //                           beforeTextPaste: (text) {
  //                             print("Allowing to paste $text");
  //                             //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
  //                             //but you can show anything you want here, like your pop up saying wrong paste format or etc
  //                             return true;
  //                           },
  //                         )),
  //                   ),
  //                 ]),
  //           ),
  //           actions: [
  //             Row(
  //               children: [
  //                 Expanded(
  //                     child: ElevatedButton(
  //                         style: ButtonStyle(
  //                           backgroundColor: MaterialStateProperty.resolveWith<Color>(
  //                                 (Set<MaterialState> states) => Colors.white,
  //                           ),
  //                           shape: MaterialStateProperty.all(
  //                               RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(4.0),
  //                               )
  //                           ),
  //                         ),
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                         },
  //                         child: const Padding(
  //                           padding: EdgeInsets.symmetric(vertical: 4.0),
  //                           child: Text(
  //                             'Cancel',
  //                             style: TextStyle(
  //                                 color: Colors.black),
  //                             textAlign: TextAlign.center,
  //                           ),
  //                         )
  //                     )
  //                 ),
  //                 SizedBox(
  //                   width: 16,
  //                 ),
  //                 Expanded(
  //                     child: ElevatedButton(
  //                         style: ButtonStyle(
  //                           backgroundColor: MaterialStateProperty.resolveWith<Color>(
  //                                 (Set<MaterialState> states) => PRIMARY_COLOR,
  //                           ),
  //                           shape: MaterialStateProperty.all(
  //                               RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(4.0),
  //                               )
  //                           ),
  //                         ),
  //                         onPressed: () {
  //                           setState(() {
  //                             sentOtp = true;
  //                           });
  //                           Navigator.of(context).pop();
  //                           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
  //                         },
  //                         child: const Padding(
  //                           padding: EdgeInsets.symmetric(vertical: 4.0),
  //                           child: Text(
  //                             'Submit',
  //                             style: TextStyle(
  //                                 color: Colors.white),
  //                             textAlign: TextAlign.center,
  //                           ),
  //                         )
  //                     )
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _toggleObscureText() {
  //   setState(() {
  //     _obscureText = !_obscureText;
  //     if (_obscureText == true) {
  //       _iconVisible = Icons.visibility_off;
  //     } else {
  //       _iconVisible = Icons.visibility;
  //     }
  //   });
  // }

  // void loginWithPhone() async {
  //   auth.verifyPhoneNumber(
  //     phoneNumber: phoneController.text,
  //     verificationCompleted: (PhoneAuthCredential credential) async {
  //       await auth.signInWithCredential(credential).then((value){
  //         print("You are logged in successfully");
  //       });
  //     },
  //     verificationFailed: (FirebaseAuthException e) {
  //       print(e.message);
  //     },
  //     codeSent: (String verificationId, int? resendToken) {
  //       otpVisibility = true;
  //       verificationID = verificationId;
  //       isLoading=false;
  //       setState(() {});
  //     },
  //     codeAutoRetrievalTimeout: (String verificationId) {
  //
  //     },
  //   );
  // }

  // void verifyOTP() async {
  //   PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationID, smsCode: otpController.text);
  //
  //   await auth.signInWithCredential(credential).then((value) async {
  //     Fluttertoast.showToast(
  //         msg: "You are logged in successfully",
  //         toastLength: Toast.LENGTH_SHORT,
  //         fontSize: 16.0
  //     );
  //     setState(() {
  //       isLoading=false;
  //     });
  //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
  //     const Home()));
  //   });
  // }

  @override
  void initState() {
    super.initState();
    phoneController.text = "+91";
    SigninPage.init();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Container(
              height: 350.0,
              width: 300.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36.0),
                  image: const DecorationImage(
                      image: AssetImage(
                        "assets/images/signup.png",
                      ),
                      fit: BoxFit.cover)),
            ),
          ),
          const Text(
            'Sign In',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            keyboardType: TextInputType.phone,
            controller: phoneController,
            style: const TextStyle(color: Colors.black54),
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
          TextFormField(
            obscureText: _obscureText,
            style: const TextStyle(color: Colors.black54),
            controller: passController,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: PRIMARY_COLOR, width: 2.0)),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFCCCCCC)),
              ),
              labelText: 'Password',
              labelStyle: TextStyle(color: textColor),
              suffixIcon: IconButton(
                  icon: Icon(_iconVisible, color: Colors.grey, size: 20),
                  onPressed: () {
                    _toggleObscureText();
                  }),
            ),
          ),
          // Visibility(child: Container(
          //   margin: EdgeInsets.only(top: 10),
          //   child: TextField(
          //     controller: otpController,
          //     decoration: InputDecoration(
          //         hintText: "Enter OTP here..."
          //     ),
          //     keyboardType: TextInputType.number,
          //   ),
          // ),visible: otpVisibility,),
          const SizedBox(
            height: 20,
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: PRIMARY_COLOR,
                  ),
                )
              : ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => PRIMARY_COLOR,
                    ),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    )),
                  ),
                  onPressed: () async {
                    await SigninPage.init();
                    if (phoneController.text == "+919579235986" &&
                        passController.text == "Kartik@986") {
                      setState(() {
                        isLoading = true;
                      });
                      login().then((value) {
                      prefs.setString("isLoggedIn", "1");
                      prefs.setString("mobile", phoneController.text);
                          Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (context) => Home()));
                      });
                    } else if (phoneController.text == "+917588807491" &&
                        passController.text == "Hemant@007") {
                      setState(() {
                        isLoading = true;
                      });
                    login().then((value) {
                    prefs.setString("isLoggedIn", "1");
                    prefs.setString("mobile", phoneController.text);
                    Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Home()));
                    });
                    } else {
                      Fluttertoast.showToast(
                          msg: "Check Phone no. and password");
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      // otpVisibility ? "Verify" :
                      "Login",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  )),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    ));
  }
}
