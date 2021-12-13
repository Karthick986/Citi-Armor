import 'dart:async';
import 'dart:io';
import 'package:citi_policemen/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';
import 'home.dart';

late SharedPreferences prefs;

class NotificationService {
static final NotificationService _notificationService =
NotificationService._internal();

factory NotificationService() {
  return _notificationService;
}

NotificationService._internal();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> init() async {
  final AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('flutter');

  final IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );

  final InitializationSettings initializationSettings =
  InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: null);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
}

void selectNotification(String? payload) async {
  //Handle notification tapped logic here
}
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void _requestPermissions() {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      MacOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  HttpOverrides.global = MyHttpOverrides();

  RemoteNotification? notification = message.notification;

  // var attachmentPicturePath = message.data["order_id"] == ''
  //     ? await _downloadAndSaveFile(
  //     'https://ecart.cluematrix.in/public/uploads/images/notification/' +
  //         message.data["image"].toString(),
  //     'Attach')
  //     : await _downloadAndSaveFile(
  //     'https://ecart.cluematrix.in/public/uploads/images/product/' +
  //         message.data["image"].toString(),
  //     'Attach');
  //
  // var bigPictureStyleInformation = BigPictureStyleInformation(
  //   FilePathAndroidBitmap(attachmentPicturePath),
  // );

  await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      message.notification!.title.toString(),
      message.notification!.body.toString(),
      NotificationDetails(
          android: AndroidNotificationDetails(
            "10101",
            "Damini-Cop",
            channelDescription: "Description",
            color: PRIMARY_COLOR,
            playSound: true,
            icon: 'flutter',
            channelShowBadge: true,
            enableLights: true,
            enableVibration: true,
            priority: Priority.high,
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
          iOS: IOSNotificationDetails(
            presentBadge: true,
            presentAlert: true,
            presentSound: true,
          )),
      payload: message.toString());
}

FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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
  await NotificationService().init();
  await Firebase.initializeApp();

  _requestPermissions();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Damini Cop',
      theme: ThemeData(
        primaryColor: PRIMARY_COLOR,
        primaryColorDark: PRIMARY_COLOR,
        fontFamily: 'ABeeZee'
      ),
      home: SplashScreenPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  Timer? _timer;
  int _second = 3; // set timer for 3 second and then direct to next page

  void _startTimer() async {
    await SplashScreenPage.init();

    const period = Duration(seconds: 1);
    _timer = Timer.periodic(period, (timer) {
      setState(() {
        _second--;
      });
      if (_second == 0) {
        _cancelFlashsaleTimer();
        // for this example we will use pushReplacement because we want to go back to the list
        if (prefs.getString("isLoggedIn")=="0" || prefs.getString("isLoggedIn")==null) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => SigninPage()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Home()));
        }

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
    SplashScreenPage.init();
    Firebase.initializeApp();

    _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("notify----------> " + message.notification.toString());
      RemoteNotification? notification = message.notification;
      // AndroidNotification? android = message.notification?.android;
      //
      // var attachmentPicturePath = message.data["order_id"] == ''
      //     ? await _downloadAndSaveFile(
      //     'https://ecart.cluematrix.in/public/uploads/images/notification/' +
      //         message.data["image"].toString(),
      //     'Attach')
      //     : await _downloadAndSaveFile(
      //     'https://ecart.cluematrix.in/public/uploads/images/product/' +
      //         message.data["image"].toString(),
      //     'Attach');

      // var iOSPlatformSpecifics = IOSNotificationDetails(
      //   attachments: [IOSNotificationAttachment(attachmentPicturePath)],
      // );

      // var bigPictureStyleInformation = BigPictureStyleInformation(
      //   FilePathAndroidBitmap(attachmentPicturePath),
      // );

      // if (notification != null && android != null) {
      await flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          NotificationDetails(
              android: AndroidNotificationDetails(
                "10101",
                "Damini-Cop",
                channelDescription: "Description",
                color: PRIMARY_COLOR,
                playSound: true,
                icon: 'flutter',
                channelShowBadge: true,
                enableLights: true,
                enableVibration: true,
                priority: Priority.high,
                largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              ),
              iOS: const IOSNotificationDetails(
                presentBadge: true,
                presentAlert: true,
                presentSound: true,
              )),
          payload: message.data.toString());
    });
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
                              'Damini-Cop',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            margin: EdgeInsets.only(top: 10.0),
                          )
                        ],
                      )),
                ),
              ),
              // Container(
              //   alignment: Alignment.bottomCenter,
              //   child: Text(
              //     'Developed by',
              //     style: TextStyle(color: textColor, fontSize: 13),
              //   ),
              //   margin: EdgeInsets.all(3.0),
              // ),
              // Container(
              //     alignment: Alignment.bottomCenter,
              //     child: Text(
              //       'Cluematrix Technologies Private Limited',
              //       style: TextStyle(color: PRIMARY_COLOR, fontSize: 15.0, fontWeight: FontWeight.bold),
              //     ),
              //     margin: EdgeInsets.only(bottom: 16.0)),
            ],
          ),
        ));
  }
}
