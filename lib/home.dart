import 'dart:async';
import 'dart:typed_data';
import 'package:citi_policemen/signin.dart';
import 'package:citi_policemen/userinfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as lac;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'app_constants.dart';
import 'dart:ui' as ui;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class AppConstant {
  static List<Map<String, dynamic>> list = [
    {"title": "one", "id": "1", "lat": 21.122591, "lon": 79.1414301},
    {"title": "two", "id": "2", "lat": 21.123533, "lon": 79.1444352},
    {"title": "three", "id": "3", "lat": 21.12271, "lon": 79.149478},
  ];
}

class _HomeState extends State<Home> {
  LatLng _initialcameraposition = LatLng(0, 0);
  late GoogleMapController _gcontroller;
  Completer<GoogleMapController> _controller = Completer();
  // Set<Circle> circles = {};

  void showLogout(context) {
    // set up the buttons
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('No', style: TextStyle(color: PRIMARY_COLOR)));
    Widget continueButton = TextButton(
        onPressed: () {
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

  _showUserInfo(id, lat, long) async {
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
            child: UserInfo(userId: id, lat: lat, long: long,));
      },
    );
  }

  Set<Circle> circles = Set.from([Circle(
    circleId: CircleId("1"),
    center: LatLng(23.7985053, 90.3842538),
    radius: 2000,
    fillColor: Colors.transparent,
    strokeColor: Color(0xff96ffca),
    strokeWidth: 250
  )]);

  // Iterable markers = [];

  // void _onMapCreated() {
  //   _location.onLocationChanged.listen((l) async {
  //     circles = Set.from([Circle(
  //       circleId: CircleId("id"),
  //       center: LatLng(AppConstant.list[0]['lat'],AppConstant.list[0]['lon'],),
  //       radius: 4000,
  //     )]);
  //   });
  // }

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

  // Future<Uint8List> changeIcon(index) async {
  //   index = await getBytesFromAsset('assets/images/mark_green.png', 100);
  //   setState(() {});
  //   return markerIcon;
  // }

  Iterable markers = [];

  Future setMarkers(Iterable _markers) async {
    await getIcon();
    _markers = Iterable.generate(
        AppConstant.list.length, (index) {
      return Marker(
        icon: BitmapDescriptor.fromBytes(markerIcon),
        markerId: MarkerId(AppConstant.list[index]['id']),
        position: LatLng(
          AppConstant.list[index]['lat'],
          AppConstant.list[index]['lon'],
        ),
        onTap: () {
          // print(_markers.elementAt(index));
          _showUserInfo(AppConstant.list[index]['id'],
              AppConstant.list[index]['lat'].toString(), AppConstant.list[index]['lon'].toString());
        },
      );
    });
    setState(() {
      markers = _markers;
    });
  }

  // Future<Position> getLocation() async {
  //   var currentLocation;
  //   try {
  //     currentLocation = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: lac.LocationAccuracy.best);
  //   } catch (e) {
  //     currentLocation = null;
  //   }
  //   return currentLocation;
  // }
  //
  // Future showLatlong() async {
  //   Position position = await getLocation();
  //   print(position.latitude.toString()+" "+position.longitude.toString());
  //   await GetAddressFromLatLong(position);
  // }
  //
  // Future<void> GetAddressFromLatLong(Position position)async {
  //   List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
  //   print(placemarks);
  //   Placemark place = placemarks[0];
  //   print(place.street);
  // }

  @override
  void initState() {
    // _onMapCreated();
    // showLatlong();
    setMarkers(markers);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Citi Police',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: PRIMARY_COLOR,
        actions: [
          TextButton(onPressed: () {
            showLogout(context);
          }, child: Text("Logout", style: TextStyle(color: Colors.white),))
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(21.1225911, 79.1414301),
                  zoom: 16),
              // initialCameraPosition:
              // CameraPosition(target: _initialcameraposition),
              mapType: MapType.normal,
              // onMapCreated: _onMapCreated,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              compassEnabled: true,
              indoorViewEnabled: true,
              zoomGesturesEnabled: true,
              markers: Set.from(
                markers,
              ),
            ),
          ),
        ],
      ),
    );
  }
}