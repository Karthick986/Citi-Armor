import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' as IO;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:citi_police/app_constants.dart';
import 'package:citi_police/signin.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../home.dart';

class SignupPage extends StatefulWidget {
  final bool fromList;

  const SignupPage({Key? key, this.fromList = false}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _etPhone = TextEditingController();
  final TextEditingController _etName = TextEditingController();
  bool _obscureText = true;
  IconData _iconVisible = Icons.visibility_off;

  bool sentOtp = false;

  final formKey = GlobalKey<FormState>();
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  bool hasError = false;
  String currentText = "";

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
                        child: Icon(Icons.camera, size: 96,),
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(0);
                        },
                      ),
                      SizedBox(width: 16.0,),
                      InkWell(
                        child: Icon(Icons.photo, size: 96,),
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

  Future<void> showOTPDialog(context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            'Verify OTP',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                color: PRIMARY_COLOR,
                fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 8.0),
                      padding: EdgeInsets.all(4.0),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        'OTP Code has been sent to your mobile number',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      color: PRIMARY_COLOR,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8.0,
              ),
              Container(
                  child: Text('Enter OTP here...',
                      style: TextStyle(color: PRIMARY_COLOR))),
              Form(
                key: formKey,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 50),
                    child: PinCodeTextField(
                      appContext: context,
                      pastedTextStyle: TextStyle(
                          // color: Colors.green.shade600,
                          // fontWeight: FontWeight.bold,
                          ),
                      length: 4,
                      // obscureText: true,
                      // obscuringCharacter: '*',
                      // obscuringWidget: FlutterLogo(
                      //   size: 24,
                      // ),
                      blinkWhenObscuring: true,
                      animationType: AnimationType.fade,
                      // validator: (v) {
                      //   if (v!.length < 4) {
                      //     return "Invalid OTP Code";
                      //   } else {
                      //     return null;
                      //   }
                      // },
                      pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white),
                      cursorColor: PRIMARY_COLOR,
                      animationDuration: Duration(milliseconds: 300),
                      enableActiveFill: true,
                      // errorAnimationController: errorController,
                      // controller: textEditingController,
                      keyboardType: TextInputType.number,
                      boxShadows: [
                        BoxShadow(
                          offset: Offset(0, 1),
                          color: Colors.black12,
                          blurRadius: 10,
                        )
                      ],
                      onCompleted: (v) {
                        print("Completed");
                      },
                      // onTap: () {
                      //   print("Pressed");
                      // },
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          currentText = value;
                        });
                      },
                      beforeTextPaste: (text) {
                        print("Allowing to paste $text");
                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                        return true;
                      },
                    )),
              ),
            ]),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => Colors.white,
                          ),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          )),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ))),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => PRIMARY_COLOR,
                          ),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          )),
                        ),
                        onPressed: () {
                          setState(() {
                            sentOtp = true;
                          });
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Home()));
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ))),
              ],
            ),
          ],
        );
      },
    );
  }

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _etPhone.dispose();
    _etName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
      onWillPop: () {
        FocusScope.of(context).unfocus();
        return Future.value(true);
      },
      child: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
          children: <Widget>[
            Container(
              alignment: Alignment.center,
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
              'Sign Up',
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              keyboardType: TextInputType.text,
              controller: _etName,
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
            const SizedBox(
              height: 20.0,
            ),
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: _etPhone,
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
            SizedBox(
              height: 8.0,
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
                        left: 30.0, right: 30.0, top: 20.0, bottom: 20.0),
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
            const SizedBox(
              height: 24,
            ),
            TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) => PRIMARY_COLOR,
                  ),
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  )),
                ),
                onPressed: () {
                  //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false);
                  // if(!widget.fromList){
                  //   Navigator.pop(context);
                  // }
                  showOTPDialog(context);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Text(
                    'Register',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                )),
            const SizedBox(
              height: 16,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SigninPage()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already Registered! Login Here ',
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
