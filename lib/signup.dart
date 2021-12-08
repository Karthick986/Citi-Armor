import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../home.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController(text: "+91");
  TextEditingController otpController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  bool otpVisibility = false;

  String verificationID = "";

  IO.File? _imageFile;
  late String byteImage;
  bool isLoading = false;
  final picker = ImagePicker();

  Future pickImage(int i) async {
    switch (i) {
      case 0:
        final pickedFile = await picker.getImage(source: ImageSource.camera);
        setState(() {
          _imageFile = IO.File(pickedFile!.path);
        });
        break;
      case 1:
        final pickedFile = await picker.getImage(source: ImageSource.gallery);
        setState(() {
          _imageFile = IO.File(pickedFile!.path);
        });
        break;
    }
  }

  Future _showImageOptions(context) async {
    return await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0))),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Take photo from'),
                  SizedBox(height: 8.0,),
                  Row(
                    children: [
                      InkWell(
                        child: Icon(Icons.camera, size: 60,),
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(0);
                        },
                      ),
                      SizedBox(width: 16.0,),
                      InkWell(
                        child: Icon(Icons.photo, size: 60,),
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(1);
                        },
                      )
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }

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
                        "assets/images/signup.jpeg",
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
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            keyboardType: TextInputType.name,
            controller: nameController,
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
              labelText: 'Name',
              labelStyle: TextStyle(color: textColor),
            ),
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
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Container(
              child: const Text(
                'Choose image: ',
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 100.0,
                  margin: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
                  child: ClipRRect(
                    child: (_imageFile != null)
                        ? Image.file(_imageFile!)
                        : ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) => Colors.white24,
                          ),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              )),
                        ),
                        onPressed: () {
                          _showImageOptions(context);
                        },
                        child: Text(
                          'Click here to pick',
                          style:
                          TextStyle(fontSize: 13, color: textColor),
                          textAlign: TextAlign.center,
                        )),
                  ),
                ),
                (_imageFile != null)
                    ? ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => Colors.white24,
                      ),
                      shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          )),
                    ),
                    onPressed: () {
                      _showImageOptions(context);
                    },
                    child: Text(
                      'Re-take',
                      style: TextStyle(fontSize: 13, color: textColor),
                      textAlign: TextAlign.center,
                    ))
                    : SizedBox(),
              ],
            ),
          ]),
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
                if(otpVisibility){
                  verifyOTP();
                }
                else {
                  setState(() {
                    isLoading=true;
                  });
                  loginWithPhone();
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

  void verifyOTP() async {

    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationID, smsCode: otpController.text);

    await auth.signInWithCredential(credential).then((value) async {
      Fluttertoast.showToast(
          msg: "You are logged in successfully",
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0
      );
      await FirebaseFirestore.instance
          .collection("Users").doc(auth.currentUser!.uid)
          .set({'name': nameController.text, 'mobile': phoneController.text, "lat": "0", "long": "0"});
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
      const Home()));
    });
  }
}
