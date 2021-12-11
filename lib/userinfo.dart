import 'dart:async';
import 'package:citi_policemen/resolve_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_constants.dart';
import 'dart:io' as IO;
import 'package:image_picker/image_picker.dart';

class MapUtils {
  MapUtils._();

  static void openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      Fluttertoast.showToast(msg: "Could not open the map!");
      throw 'Could not open the map.';
    }
  }

  static void navigateTo(double lat, double lng) async {
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      Fluttertoast.showToast(msg: "Could not open the map!");
      throw 'Could not launch ${uri.toString()}';
    }
  }
}

// ignore: must_be_immutable
class UserRelatedInfo extends StatefulWidget {
  String lat, long, userId, name, mobile, datetime, token;

  UserRelatedInfo(
      {Key? key,
      required this.userId,
      required this.lat,
      required this.long,
      required this.name,
      required this.mobile,
      required this.token,
      required this.datetime})
      : super(key: key);

  @override
  _UserRelatedInfoState createState() => _UserRelatedInfoState();
}

class _UserRelatedInfoState extends State<UserRelatedInfo> {
  IO.File? _imageFile;
  late String byteImage;
  bool isLoading = false;
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      _imageFile = IO.File(pickedFile!.path);
    });
  }

  Future<void> _showResolve(context, uid, name, token) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text("Resolve"),
              content: ResolveDialog(
                userId: uid,
                name: name,
                token: token,
              ));
        });
  }

  _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _createUserInfo();
  }

  Widget _createUserInfo() {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                child: FlutterLogo(
                  size: 60,
                ),
                margin: EdgeInsets.all(8.0),
              ),
              Container(
                  margin: EdgeInsets.all(8.0),
                  child: Text(widget.name,
                      style: TextStyle( fontSize: 16.0))),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          margin: EdgeInsets.all(8.0),
                          child: Wrap(children: [
                            Text("Time: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16.0)),
                            Text(widget.datetime, style: TextStyle(fontSize: 16.0))
                          ])),
                      SizedBox(
                        height: 8.0,
                      ),
                      Container(
                          margin: EdgeInsets.all(8.0),
                          child: Wrap(children: [
                            Text("Mobile No: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16.0)),
                            Text(widget.mobile,
                                style: TextStyle( fontSize: 16.0))
                          ]))
                    ]),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.all(4.0),
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => PRIMARY_COLOR,
                          ),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          )),
                        ),
                        onPressed: () {
                          _showResolve(
                              context, widget.userId, widget.name, widget.token);
                        },
                        child: Text(
                          'Resolve',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Container(
                    margin: EdgeInsets.all(4.0),
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => textColor,
                          ),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          )),
                        ),
                        onPressed: () {
                          _callNumber(widget.mobile);
                        },
                        child: Text(
                          'Call',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Container(
                    margin: EdgeInsets.all(4.0),
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => Colors.grey,
                          ),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          )),
                        ),
                        onPressed: () {
                          MapUtils.navigateTo(
                              double.parse(widget.lat), double.parse(widget.long));
                        },
                        child: Text(
                          'Directions',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
