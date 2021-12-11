import 'dart:async';
import 'dart:typed_data';
import 'package:citi_policemen/signin.dart';
import 'package:citi_policemen/userinfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';
import 'dart:ui' as ui;

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
  late GoogleMapController _gcontroller;
  Completer<GoogleMapController> _controller = Completer();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  Location location = Location();
  // Set<Circle> circles = {};
  static late double lat=0, long=0;
  bool markersAdded=false;

  static List<Map<String, dynamic>> list = [];

  Future getLatLng() async {
    _locationData = await location.getLocation();
    setState(() {
      lat = _locationData.latitude!;
      long = _locationData.longitude!;
    });
    Fluttertoast.showToast(msg: "Current Location found!");
  }

  Future getCloudFirestoreUsers() async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.collection("Users").get().then((querySnapshot) {
      setState(() {
      for (var value in querySnapshot.docs) {
        if (value["lat"]!="0" || value["long"]!="0") {
          list.add({
            "lat": value["lat"],
            "long": value["long"],
            "uid": value["uid"],
            "name": value["name"],
            "mobile": value["mobile"],
            "datetime": value["datetime"],
            "token": value["token"]
          });
        }
      }
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  void showLogout(context) {
    // set up the buttons
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('No', style: TextStyle(color: PRIMARY_COLOR)));
    Widget continueButton = TextButton(
        onPressed: () async {
          await Home.init();
          prefs.setString("isLoggedIn", "0");
          Navigator.of(context).pop();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => SigninPage()));
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

  _showUserInfo(lat, long, uid, name, mobile, datetime, token) async {
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
            child: UserRelatedInfo(userId: uid, lat: lat, long: long, name: name, mobile: mobile, datetime: datetime, token: token,));
      },
    );
  }

  // Set<Circle> circles = Set.from([Circle(
  //   circleId: CircleId("1"),
  //   center: LatLng(lat, long),
  //   radius: 2000,
  //   fillColor: Colors.grey,
  //   strokeColor: Color(0xff96ffca),
  //   strokeWidth: 250
  // )]);

  // Iterable markers = [];

  late Uint8List markerIcon;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<Uint8List> getIcon() async {
    markerIcon = await getBytesFromAsset('assets/images/mark_red.png', 100);
    return markerIcon;
  }

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

  Iterable markers = [];

  Future setMarkers(Iterable _markers) async {
    await getIcon();
    _markers = Iterable.generate(
        list.length, (index) {
      return Marker(
        icon: BitmapDescriptor.fromBytes(markerIcon),
        markerId: MarkerId(index.toString()),
        position: LatLng(
          double.parse(list[index]['lat'].toString()),
      double.parse(list[index]['long'].toString())),
        onTap: () {
          _showUserInfo(list[index]['lat'].toString(), list[index]['long'].toString(), list[index]['uid'].toString(), list[index]['name'].toString(),
              list[index]['mobile'].toString(), list[index]['datetime'].toString(), list[index]['token'].toString());
        },
      );
    });
    setState(() {
      markers = _markers;
    });
  }

  @override
  void initState() {
    super.initState();
    Home.init();
    checkPermission();
    Firebase.initializeApp();
    getCloudFirestoreUsers();
    setMarkers(markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Damini-Cop',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: PRIMARY_COLOR,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(onPressed: () {
              Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => Home()));
            }, child: Text("Refresh", style: TextStyle(color: Colors.white),)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(onPressed: () {
              showLogout(context);
            }, child: Icon(Icons.logout, color: Colors.white,)),
          )
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: markers.isNotEmpty ? GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(lat, long)),
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              markers: Set.from(
                markers,
              ),
            ) : Center(child: CircularProgressIndicator(color: PRIMARY_COLOR,),),
          ),
        ],
      ),
    );
  }
}