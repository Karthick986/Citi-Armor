import 'package:citi_police/app_constants.dart';
import 'package:citi_police/signin.dart';
import 'package:citi_police/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'issue_dialog.dart';

late SharedPreferences prefs;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }
}

class _HomeState extends State<Home> {
  String lat="", long="";

  Location location = Location();

  Future<void> _showResolve(context) async {
    return showDialog(barrierDismissible: false, context: context, builder: (_) {
      return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text("Raise Issue"), content: IssueDialog());
    });
  }

  getLatLng() async {
    _locationData = await location.getLocation();
    setState(() {
      lat = _locationData.latitude.toString();
      long = _locationData.longitude.toString();
    });
    DateFormat dateFormat = DateFormat("yyyy-MM-dd, HH:mm");
    String dateTime = dateFormat.format(DateTime.now());
    Navigator.pop(context);
    if (lat.isNotEmpty && long.isNotEmpty) {
      Fluttertoast.showToast(msg: "Current Location found!");
      await FirebaseFirestore.instance
          .collection("Users").doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'lat': lat, 'long': long, "datetime": dateTime});
      _showResolve(context);
    } else {
      Fluttertoast.showToast(msg: "Location not found!");
    }
  }

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  Future checkPermission() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  Future getData() async {
    var document = FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid);
    document.get().then((value) {
      setState(() {
        lat = value["lat"];
        long = value["long"];
      });
    });
  }

  Future _progressDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Center(
              child: CircularProgressIndicator(),
            );
        });
  }

  void showLogout(context) async {
    await Home.init();
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('No', style: TextStyle(color: PRIMARY_COLOR)));
    Widget continueButton = TextButton(
        onPressed: () {
          prefs.setString("isLoggedIn", "0");
          FirebaseAuth.instance.signOut();
          Navigator.of(context).pop();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => SignupPage()));
        },
        child: Text('Yes', style: TextStyle(color: PRIMARY_COLOR)));

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      title: const Text(
        'Confirm Logout',
        style: TextStyle(fontSize: 16),
      ),
      content: Text('Are you sure want to logout ?',
          style: TextStyle(fontSize: 13, color: textColor)),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
    Firebase.initializeApp();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: PRIMARY_COLOR,
        title: Text("Damini-User"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(onPressed: () {
              showLogout(context);
            }, child: Text("Logout", style: TextStyle(color: Colors.white),)),
          )
        ],
      ),
        body: RefreshIndicator(
          strokeWidth: 2,
          color: PRIMARY_COLOR,
          onRefresh: () async {
            await Future.delayed(Duration(milliseconds: 1000));
            Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                    pageBuilder: (_, __, ___) => Home()));
          }, child: lat.isEmpty || long.isEmpty ? Center(
      child: CircularProgressIndicator(color: PRIMARY_COLOR,),) : (lat!="0"&&long!="0")
          ? Column(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                        constraints:
                            BoxConstraints.tightFor(width: MediaQuery.of(context).size.width/2, height: MediaQuery.of(context).size.width/2),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xff5F0606),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    MediaQuery.of(context).size.width / 2))),
                          ),
                          child: Text("OFF", style: TextStyle(fontSize: MediaQuery.of(context).size.width/8),),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("Users").doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({'lat': "0", 'long': "0", "datetime": ""});
                            Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => Home()));
                          },
                        )),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(bottom: 16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tightFor(width: MediaQuery.of(context).size.width/3),
                      child: ElevatedButton(
                        child: Text("Force Close"),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xff5F0606),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0))),
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection("Users").doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({'lat': "0", 'long': "0", "datetime": ""});
                          Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => Home()));
                        },
                      ),
                    ))
              ],
            )
          : Center(
            child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: MediaQuery.of(context).size.width/1.5, height: MediaQuery.of(context).size.width/1.5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: PRIMARY_COLOR,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(
                            MediaQuery.of(context).size.width / 2))),
                  ),
                  child: Text("ON", style: TextStyle(fontSize: MediaQuery.of(context).size.width/8),),
                  onPressed: () {
                    _progressDialog(context);
                    getLatLng();
                  },
                )),
          ),
    ));
  }
}
