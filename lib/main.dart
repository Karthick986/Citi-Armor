import 'dart:io';
import 'package:citi_police/onboarding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'app_constants.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host,
          int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashScreenPage(),
      title: "Citi Aromor",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: PRIMARY_COLOR,
          primaryColorDark: PRIMARY_COLOR,
          fontFamily: 'ABeeZee'
      ),);
  }
}

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  Timer? _timer;
  int _second = 3; // set timer for 3 second and then direct to next page

  void _startTimer() {
    const period = Duration(seconds: 1);
    _timer = Timer.periodic(period, (timer) {
      setState(() {
        _second--;
      });
      if (_second == 0) {
        _cancelFlashsaleTimer();
        // for this example we will use pushReplacement because we want to go back to the list
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => OnboardingPage()));

        // if you use this splash screen on the very first time when you open the page, use below code
        //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => OnBoardingPage()), (Route<dynamic> route) => false);
      }
    });
  }

  void _cancelFlashsaleTimer() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void initState() {
    // set status bar color to transparent and navigation bottom color to black21
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    if (_second != 0) {
      _startTimer();
    }
    super.initState();
  }

  @override
  void dispose() {
    _cancelFlashsaleTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: Column(
            children: [
              WillPopScope(
                onWillPop: () {
                  return Future.value(false);
                },
                child: Expanded(
                  child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 150.0,
                            height: 150.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: FlutterLogo(size: MediaQuery.of(context).size.width/2,),
                          ),
                          Container(
                            child: Text(
                              'Citi-Armor',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            margin: EdgeInsets.only(top: 10.0),
                          )
                        ],
                      )),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Developed by',
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
                margin: EdgeInsets.all(3.0),
              ),
              Container(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'Cluematrix Technologies Private Limited',
                    style: TextStyle(color: PRIMARY_COLOR, fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                  margin: EdgeInsets.only(bottom: 16.0)),
            ],
          ),
        ));
  }
}