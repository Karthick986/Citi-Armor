import 'dart:async';
import 'package:citi_policemen/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citi Armor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreenPage(),
      debugShowCheckedModeBanner: false,
    );
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
            MaterialPageRoute(builder: (context) => SigninPage()));

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
                          // Container(
                          //   child: Text(
                          //     'Design with love in India',
                          //     style: TextStyle(
                          //         color: Colors.white, fontSize: 15.0, fontFamily: 'Bariol-Bold'),
                          //   ),
                          //   margin: EdgeInsets.only(top: 10.0),
                          // )
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
