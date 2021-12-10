import 'package:citi_police/page_model.dart';
import 'package:citi_police/signin.dart';
import 'package:citi_police/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';
import 'overroad.dart';

late SharedPreferences prefs;

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }
}

class _OnboardingPageState extends State<OnboardingPage> {
  // create each page of onBoard here
  final _pageList = [
    PageModel(
        color: Colors.white,
        imageAssetPath: 'assets/images/1.png',
        title: 'Tutorial 1',
        body: 'This is description of tutorial 1. Lorem ipsum dolor sit amet.',
        doAnimateImage: true),
    PageModel(
        color: Colors.white,
        imageAssetPath: 'assets/images/2.png',
        title: 'Tutorial 2',
        body: 'This is description of tutorial 2. Lorem ipsum dolor sit amet.',
        doAnimateImage: true),
    PageModel(
        color: Colors.white,
        imageAssetPath: 'assets/images/3.png',
        title: 'Tutorial 3',
        body: 'This is description of tutorial 3. Lorem ipsum dolor sit amet.',
        doAnimateImage: true),
    // PageModel(
    //     color: Colors.white,
    //     imageAssetPath: 'assets/images/signup.jpg',
    //     title: 'Tutorial 4',
    //     body: 'This is description of tutorial 4. Lorem ipsum dolor sit amet.',
    //     doAnimateImage: true),
  ];

  @override
  void initState() {
    super.initState();
    OnboardingPage.init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark
          ),
          child: OverBoard(
            pages: _pageList,
            showBullets: true,
            finishCallback: () async {
              await OnboardingPage.init();
              prefs.setString('onBoard', '1');
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
              const SignInPage()));
            },
          ),
        )
    );
  }
}