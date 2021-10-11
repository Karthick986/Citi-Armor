import 'package:citi_police/app_constants.dart';
import 'package:citi_police/signin.dart';
import 'package:flutter/material.dart';
// import 'package:location/location.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isPressed = false;

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

  // bool _serviceEnabled;
  // PermissionStatus _permissionGranted;
  // LocationData _userLocation;
  //
  // Future<void> _getUserLocation() async {
  //   Location location = new Location();
  //
  //   // Check if location service is enable
  //   _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled) {
  //       return;
  //     }
  //   }
  //
  //   // Check if permission is granted
  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       return;
  //     }
  //   }
  //
  //   final _locationData = await location.getLocation();
  //   setState(() {
  //     _userLocation = _locationData;
  //   });
  // }

  @override
  void initState() {
    // _getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: PRIMARY_COLOR,
        title: Text("Citi Armor"),
        actions: [
          TextButton(onPressed: () {
            showLogout(context);
          }, child: Text("Logout", style: TextStyle(color: Colors.white),))
        ],
      ),
        body: Center(
      child: (isPressed)
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
                          onPressed: () {},
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
                        onPressed: () {
                          setState(() {
                            isPressed = false;
                          });
                        },
                      ),
                    ))
              ],
            )
          : ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: MediaQuery.of(context).size.width/2, height: MediaQuery.of(context).size.width/2),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: PRIMARY_COLOR,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(
                          MediaQuery.of(context).size.width / 2))),
                ),
                child: Text("ON", style: TextStyle(fontSize: MediaQuery.of(context).size.width/8),),
                onPressed: () {
                  setState(() {
                    isPressed = true;
                  });
                },
              )),
    ));
  }
}
