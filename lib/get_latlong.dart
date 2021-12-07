import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//
// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? mapController;
//   // double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
//   // double _destLatitude = 6.849660, _destLongitude = 3.648190;
//   double _originLatitude = 21.1205473, _originLongitude = 79.1442014;
//   double _destLatitude = 21.2205489, _destLongitude = 79.3442032;
//   Map<MarkerId, Marker> markers = {};
//   Map<PolylineId, Polyline> polylines = {};
//   List<LatLng> polylineCoordinates = [];
//   PolylinePoints polylinePoints = PolylinePoints();
//   String googleAPiKey = "AIzaSyCzIepMASTe7Jbff-ZveKozUhej-Wnx2HQ";
//       // "AIzaSyCaCSJ0BZItSyXqBv8vpD1N4WBffJeKhLQ";
//
//   @override
//   void initState() {
//     super.initState();
//
//     /// origin marker
//     _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
//         BitmapDescriptor.defaultMarker);
//
//     /// destination marker
//     _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
//         BitmapDescriptor.defaultMarkerWithHue(90));
//     _getPolyline();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//           body: GoogleMap(
//             initialCameraPosition: CameraPosition(
//                 target: LatLng(_originLatitude, _originLongitude), zoom: 15),
//             myLocationEnabled: true,
//             tiltGesturesEnabled: true,
//             compassEnabled: true,
//             scrollGesturesEnabled: true,
//             zoomGesturesEnabled: true,
//             onMapCreated: _onMapCreated,
//             markers: Set<Marker>.of(markers.values),
//             polylines: Set<Polyline>.of(polylines.values),
//           )),
//     );
//   }
//
//   void _onMapCreated(GoogleMapController controller) async {
//     mapController = controller;
//   }
//
//   _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
//     MarkerId markerId = MarkerId(id);
//     Marker marker =
//     Marker(markerId: markerId, icon: descriptor, position: position);
//     markers[markerId] = marker;
//   }
//
//   _addPolyLine() {
//     PolylineId id = PolylineId("poly");
//     Polyline polyline = Polyline(
//         polylineId: id, color: Colors.red, points: polylineCoordinates);
//     polylines[id] = polyline;
//     setState(() {});
//   }
//
//   _getPolyline() async {
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//         googleAPiKey,
//         PointLatLng(_originLatitude, _originLongitude),
//         PointLatLng(_destLatitude, _destLongitude),
//         travelMode: TravelMode.driving,
//         wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
//     setState(() {
//       // if (result.points.isNotEmpty) {
//         result.points.forEach((PointLatLng point) {
//           polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//         });
//       // }
//       _addPolyLine();
//     });
//   }
// }

// class GetLatLong extends StatefulWidget {
//   const GetLatLong({Key? key}) : super(key: key);
//
//   @override
//   _GetLatLongState createState() => _GetLatLongState();
// }
//
// class _GetLatLongState extends State<GetLatLong> {
//
//   static const LatLng _center = const LatLng(33.738045, 73.084488);
//   final Set<Marker> _markers = {};
//   final Set<Polyline>_polyline={};
//
//   //add your lat and lng where you wants to draw polyline
//   LatLng _lastMapPosition = _center;
//   List<LatLng> latlng = [];
//   LatLng _new = LatLng(33.738045, 73.084488);
//   LatLng _news = LatLng(33.567997728, 72.635997456);
//
//   @override
//   void initState() {
//     super.initState();
//     latlng.add(_new);
//     latlng.add(_news);
//     _onAddMarkerButtonPressed();
//   }
//
//   void _onAddMarkerButtonPressed() {
//     setState(() {
//       _markers.add(Marker(
//         // This marker id can be anything that uniquely identifies each marker.
//         markerId: MarkerId(_lastMapPosition.toString()),
//         //_lastMapPosition is any coordinate which should be your default
//         //position when map opens up
//         position: _lastMapPosition,
//         infoWindow: InfoWindow(
//           title: 'Really cool place',
//           snippet: '5 Star Rating',
//         ),
//         icon: BitmapDescriptor.defaultMarker,
//
//       ));
//       _polyline.add(Polyline(
//         polylineId: PolylineId(_lastMapPosition.toString()),
//         visible: true,
//         points: latlng,
//         color: Colors.blue,
//       ));
//     });
//   }
//
//     @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//         //that needs a list<Polyline>
//         polylines:_polyline,
//         markers: _markers,
//         // onMapCreated: _onMapCreated,
//         myLocationEnabled:true,
//         initialCameraPosition: CameraPosition(
//           target: _center,
//           zoom: 11.0,
//         ),
//
//         mapType: MapType.normal,
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GooglePolylines extends StatefulWidget {
  GooglePolylines({Key? key}) : super(key: key);

  @override
  MyState createState() {
    return MyState();
  }
}

class MyState extends State<GooglePolylines>
    with SingleTickerProviderStateMixin {
  final globalKey = GlobalKey<ScaffoldState>();

  PointLatLng origin = PointLatLng(-1.4203339, 36.9520678);
  PointLatLng destination = PointLatLng(-1.230838, 36.6640055);

  Completer<GoogleMapController> _controller = Completer();
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  PolylineResult polylineResult = PolylineResult();

  @override
  void initState() {}

  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);

    setPolylines();
  }

  setPolylines() async {
    PolylineResult polylineResult =
    await PolylinePoints().getRouteBetweenCoordinates(
        "AIzaSyCzIepMASTe7Jbff-ZveKozUhej-Wnx2HQ", //USE YOUR GOOGLE API KEY HERE
        origin,
        destination);
    polylineResult.points.forEach((PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId('poly'),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates);

      _polylines.add(polyline);
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        zoom: 13,
        bearing: 30,
        tilt: 0,
        target: new LatLng(origin.latitude, origin.longitude));

    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text("Google Maps Polylines",
            style: TextStyle(fontSize: 16, fontFamily: "SegoeBold")),
      ),
      body: GoogleMap(
          myLocationEnabled: true,
          compassEnabled: true,
          tiltGesturesEnabled: false,
          polylines: _polylines,
          mapType: MapType.normal,
          initialCameraPosition: initialLocation,
          onMapCreated: onMapCreated),
    );
  }
}